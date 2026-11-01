import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';
import '../core/shuffle/shuffle_engine.dart';

class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  late Box<dynamic> _groupsBox;
  late Box<dynamic> _historyBox;
  late Box<dynamic> _coinTossBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _groupsBox = await Hive.openBox(AppConstants.groupsBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _coinTossBox = await Hive.openBox(AppConstants.coinTossBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    ShuffleMemory.instance.attachStorageBox(_settingsBox);
    // Clean up any previously seeded dummy groups and dummy history
    final isPurged =
        _settingsBox.get('dummy_data_purged_v3', defaultValue: false);
    if (isPurged != true) {
      await _groupsBox.clear();
      await _historyBox.clear();
      await _settingsBox.put('dummy_data_purged_v3', true);
    }

    const dummyGroupIds = [
      'cricket-6',
      'classmates',
      'project-team',
      'game-night',
    ];
    for (final dummyId in dummyGroupIds) {
      if (_groupsBox.containsKey(dummyId)) {
        await _groupsBox.delete(dummyId);
      }
    }
    final groupKeysToRemove = <dynamic>[];
    for (final key in _groupsBox.keys) {
      final val = _groupsBox.get(key);
      if (val is Map) {
        final name = (val['name'] ?? '').toString().toLowerCase().trim();
        if (name == 'cricket 6' ||
            name == 'classmates' ||
            name == 'project team' ||
            name == 'game night') {
          groupKeysToRemove.add(key);
        }
      }
    }
    for (final k in groupKeysToRemove) {
      await _groupsBox.delete(k);
    }

    final historyKeysToRemove = <dynamic>[];
    for (final key in _historyBox.keys) {
      final val = _historyBox.get(key);
      if (val is Map) {
        final gId = (val['groupId'] ?? '').toString();
        final gName = (val['groupName'] ?? '').toString().toLowerCase().trim();
        if (dummyGroupIds.contains(gId) ||
            gName == 'cricket 6' ||
            gName == 'classmates' ||
            gName == 'project team' ||
            gName == 'game night') {
          historyKeysToRemove.add(key);
        }
      }
    }
    for (final k in historyKeysToRemove) {
      await _historyBox.delete(k);
    }
  }

  // ── Groups ──

  List<Group> getGroups() {
    try {
      final list = <Group>[];
      for (final v in _groupsBox.values) {
        try {
          if (v is Map) {
            final g = Group.fromMap(Map<String, dynamic>.from(v));
            final lower = g.name.toLowerCase().trim();
            // Completely filter out any dummy groups
            if (lower != 'cricket 6' &&
                lower != 'classmates' &&
                lower != 'project team' &&
                lower != 'game night' &&
                !g.id.startsWith('cricket') &&
                !g.id.startsWith('classmates') &&
                !g.id.startsWith('project') &&
                !g.id.startsWith('game')) {
              list.add(g);
            }
          }
        } catch (e, stack) {
          // ignore: avoid_print
          print('AppRepository: Error loading group item: $e\n$stack');
        }
      }
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  Group? getGroup(String id) {
    try {
      final data = _groupsBox.get(id);
      if (data == null || data is! Map) return null;
      return Group.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveGroup(Group group) async {
    await _groupsBox.put(group.id, group.toMap());
  }

  Future<void> deleteGroup(String id) async {
    await _groupsBox.delete(id);
  }

  // ── History (Name Shuffle) ──

  List<HistoryEntry> getHistory() {
    try {
      final list = <HistoryEntry>[];
      for (final v in _historyBox.values) {
        try {
          if (v is Map) {
            list.add(HistoryEntry.fromMap(Map<String, dynamic>.from(v)));
          }
        } catch (e, stack) {
          // ignore: avoid_print
          print('AppRepository: Error loading history item: $e\n$stack');
        }
      }
      list.sort((a, b) => b.shuffledAt.compareTo(a.shuffledAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHistoryEntry(HistoryEntry entry) async {
    await _historyBox.put(entry.id, entry.toMap());
  }

  Future<void> deleteHistoryEntry(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // ── Coin Toss History ──

  List<CoinTossEntry> getCoinTossHistory() {
    try {
      final list = <CoinTossEntry>[];
      for (final v in _coinTossBox.values) {
        try {
          if (v is Map) {
            list.add(CoinTossEntry.fromMap(Map<String, dynamic>.from(v)));
          }
        } catch (e, stack) {
          // ignore: avoid_print
          print('AppRepository: Error loading coin toss item: $e\n$stack');
        }
      }
      list.sort((a, b) => b.tossedAt.compareTo(a.tossedAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCoinTossEntry(CoinTossEntry entry) async {
    await _coinTossBox.put(entry.id, entry.toMap());
  }

  Future<void> deleteCoinTossEntry(String id) async {
    await _coinTossBox.delete(id);
  }

  Future<void> clearCoinTossHistory() async {
    await _coinTossBox.clear();
  }

  // ── Settings ──

  AppSettings getSettings() {
    try {
      final data = _settingsBox.get('settings');
      if (data == null || data is! Map) return AppSettings.defaults();
      return AppSettings.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings.toMap());
  }

  // ── Export / Import ──

  Map<String, dynamic> exportData() {
    return {
      'groups': getGroups().map((g) => g.toMap()).toList(),
      'history': getHistory().map((h) => h.toMap()).toList(),
      'coinTossHistory': getCoinTossHistory().map((c) => c.toMap()).toList(),
      'settings': getSettings().toMap(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final backup = exportData();

    try {
      await _groupsBox.clear();
      await _historyBox.clear();
      await _coinTossBox.clear();
      await _settingsBox.clear();

      if (data['groups'] != null) {
        for (final g in data['groups'] as List) {
          final group = Group.fromMap(Map<String, dynamic>.from(g as Map));
          await _groupsBox.put(group.id, group.toMap());
        }
      }
      if (data['history'] != null) {
        for (final h in data['history'] as List) {
          final entry =
              HistoryEntry.fromMap(Map<String, dynamic>.from(h as Map));
          await _historyBox.put(entry.id, entry.toMap());
        }
      }
      if (data['coinTossHistory'] != null) {
        for (final c in data['coinTossHistory'] as List) {
          final entry =
              CoinTossEntry.fromMap(Map<String, dynamic>.from(c as Map));
          await _coinTossBox.put(entry.id, entry.toMap());
        }
      }
      if (data['settings'] != null) {
        final settings =
            AppSettings.fromMap(Map<String, dynamic>.from(data['settings'] as Map));
        await saveSettings(settings);
      }
    } catch (e) {
      await importData(backup);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    await _groupsBox.clear();
    await _historyBox.clear();
    await _coinTossBox.clear();
    await _settingsBox.clear();
  }
}
