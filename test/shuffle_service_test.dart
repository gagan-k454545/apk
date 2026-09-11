import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/models/models.dart';
import 'package:shuffle_master/providers/shuffle_provider.dart';

void main() {
  group('ShuffleService Tests', () {
    final shuffleService = ShuffleService();

    test('Fisher-Yates Shuffle produces non-identical orders on consecutive shuffles', () {
      final group = Group(
        id: 'test_group',
        name: 'Test Group',
        members: [
          NameEntry(name: 'Gagan'),
          NameEntry(name: 'VK'),
          NameEntry(name: 'Rahul'),
          NameEntry(name: 'Aman'),
          NameEntry(name: 'Rohit'),
        ],
      );

      List<String>? prevOrder;
      for (int i = 0; i < 100; i++) {
        final result = shuffleService.shuffle(group, previousOrder: prevOrder);
        expect(result.shuffledOrder.length, equals(5));

        if (prevOrder != null) {
          expect(result.shuffledOrder, isNot(equals(prevOrder)));
        }
        prevOrder = result.shuffledOrder;
      }
    });

    test('1000 Shuffles Uniform Distribution Test', () {
      final members = List.generate(5, (i) => NameEntry(name: 'Member $i'));
      final group = Group(id: 'g1', name: 'Group 1', members: members);

      final positionCounts = List.generate(5, (_) => List.filled(5, 0));

      for (int i = 0; i < 1000; i++) {
        final result = shuffleService.shuffle(group);
        for (int pos = 0; pos < result.shuffledOrder.length; pos++) {
          final memberName = result.shuffledOrder[pos];
          final memberIdx = int.parse(memberName.split(' ')[1]);
          positionCounts[memberIdx][pos]++;
        }
      }

      // Over 1000 shuffles with 5 items, expected average frequency per position is 200 (~20%)
      for (int m = 0; m < 5; m++) {
        for (int p = 0; p < 5; p++) {
          expect(positionCounts[m][p], greaterThan(100));
          expect(positionCounts[m][p], lessThan(300));
        }
      }
    });
  });
}
