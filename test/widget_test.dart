import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/models/name_entry.dart';
import 'package:shuffle_master/models/group.dart';
import 'package:shuffle_master/models/history_entry.dart';
import 'package:shuffle_master/models/app_settings.dart';
import 'package:shuffle_master/providers/shuffle_provider.dart';

void main() {
  group('NameEntry', () {
    test('should create with auto-generated id', () {
      final entry = NameEntry(name: 'John');
      expect(entry.id, isNotEmpty);
      expect(entry.name, 'John');
      expect(entry.isFavorite, false);
    });

    test('should serialize to map and back', () {
      final entry = NameEntry(name: 'John', isFavorite: true);
      final map = entry.toMap();
      final restored = NameEntry.fromMap(map);
      expect(restored.id, entry.id);
      expect(restored.name, entry.name);
      expect(restored.isFavorite, true);
    });

    test('should copy with changes', () {
      final entry = NameEntry(name: 'John');
      final edited = entry.copyWith(name: 'Jane', isFavorite: true);
      expect(edited.id, entry.id);
      expect(edited.name, 'Jane');
      expect(edited.isFavorite, true);
    });

    test('equality based on id and name', () {
      final a = NameEntry(id: '1', name: 'John');
      final b = NameEntry(id: '1', name: 'John');
      final c = NameEntry(id: '2', name: 'John');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Group', () {
    test('should create with auto-generated id', () {
      final group = Group(name: 'Friends');
      expect(group.id, isNotEmpty);
      expect(group.name, 'Friends');
      expect(group.members, isEmpty);
    });

    test('should calculate member count', () {
      final group = Group(
        name: 'Test',
        members: [
          NameEntry(name: 'A'),
          NameEntry(name: 'B'),
        ],
      );
      expect(group.memberCount, 2);
    });

    test('should return favorites', () {
      final group = Group(
        name: 'Test',
        members: [
          NameEntry(name: 'A', isFavorite: true),
          NameEntry(name: 'B'),
        ],
      );
      expect(group.favorites.length, 1);
      expect(group.favorites.first.name, 'A');
    });

    test('should serialize to map and back', () {
      final group = Group(
        name: 'Friends',
        members: [NameEntry(name: 'John')],
      );
      final map = group.toMap();
      final restored = Group.fromMap(map);
      expect(restored.name, group.name);
      expect(restored.members.length, 1);
      expect(restored.members.first.name, 'John');
    });

    test('should deserialize untyped Hive Map<dynamic, dynamic> without throw', () {
      final untypedMap = <dynamic, dynamic>{
        'id': 'g123',
        'name': 'Classroom',
        'members': <dynamic>[
          <dynamic, dynamic>{
            'id': 'n1',
            'name': 'Gagan',
            'isFavorite': true,
            'createdAt': '2026-09-10T10:00:00.000Z',
          }
        ],
        'createdAt': '2026-09-10T10:00:00.000Z',
        'updatedAt': '2026-09-10T10:00:00.000Z',
      };
      final restored = Group.fromMap(Map<String, dynamic>.from(untypedMap));
      expect(restored.id, 'g123');
      expect(restored.name, 'Classroom');
      expect(restored.members.length, 1);
      expect(restored.members.first.name, 'Gagan');
      expect(restored.members.first.isFavorite, true);
    });
  });

  group('HistoryEntry', () {
    test('should create with auto-generated id', () {
      final entry = HistoryEntry(
        groupId: 'g1',
        groupName: 'Friends',
        result: ['Alice', 'Bob'],
      );
      expect(entry.id, isNotEmpty);
      expect(entry.count, 2);
    });

    test('should return first place', () {
      final entry = HistoryEntry(
        groupId: 'g1',
        groupName: 'Friends',
        result: ['Alice', 'Bob', 'Charlie'],
      );
      expect(entry.firstPlace, 'Alice');
    });

    test('should serialize to map and back', () {
      final entry = HistoryEntry(
        groupId: 'g1',
        groupName: 'Friends',
        result: ['Alice', 'Bob'],
      );
      final map = entry.toMap();
      final restored = HistoryEntry.fromMap(map);
      expect(restored.groupId, entry.groupId);
      expect(restored.result, entry.result);
    });
  });

  group('AppSettings', () {
    test('should have defaults', () {
      final settings = AppSettings.defaults();
      expect(settings.themeMode, ThemeModeOption.light);
      expect(settings.totalShuffles, 0);
      expect(settings.totalCoinTosses, 0);
      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
    });

    test('should serialize to map and back', () {
      final settings = AppSettings(
        themeMode: ThemeModeOption.dark,
        totalShuffles: 42,
        totalCoinTosses: 15,
        soundEnabled: false,
        hapticEnabled: false,
      );
      final map = settings.toMap();
      final restored = AppSettings.fromMap(map);
      expect(restored.themeMode, ThemeModeOption.dark);
      expect(restored.totalShuffles, 42);
      expect(restored.totalCoinTosses, 15);
      expect(restored.soundEnabled, false);
      expect(restored.hapticEnabled, false);
    });
  });

  group('ShuffleService', () {
    test('should shuffle all members', () {
      final service = ShuffleService();
      final group = Group(
        name: 'Test',
        members: [
          NameEntry(name: 'Alice'),
          NameEntry(name: 'Bob'),
          NameEntry(name: 'Charlie'),
          NameEntry(name: 'Diana'),
        ],
      );

      final result = service.shuffle(group);
      expect(result.shuffledOrder.length, 4);
      expect(
        result.shuffledOrder.toSet(),
        {'Alice', 'Bob', 'Charlie', 'Diana'},
      );
    });

    test('should handle empty group', () {
      final service = ShuffleService();
      final group = Group(name: 'Empty');
      final result = service.shuffle(group);
      expect(result.shuffledOrder, isEmpty);
    });

    test('should handle single member', () {
      final service = ShuffleService();
      final group = Group(
        name: 'Solo',
        members: [NameEntry(name: 'Alice')],
      );
      final result = service.shuffle(group);
      expect(result.shuffledOrder, ['Alice']);
    });

    test('should produce different orders over many shuffles', () {
      final service = ShuffleService();
      final group = Group(
        name: 'Test',
        members: List.generate(20, (i) => NameEntry(name: 'Name$i')),
      );

      final results = <String>{};
      for (var i = 0; i < 100; i++) {
        final result = service.shuffle(group);
        results.add(result.shuffledOrder.join(','));
      }

      // With 20 names, 100 shuffles should produce at least a few different orders
      expect(results.length, greaterThan(1));
    });
  });
}
