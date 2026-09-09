import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';

class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  late Box<dynamic> _groupsBox;
  late Box<dynamic> _historyBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    _groupsBox = await Hive.openBox(AppConstants.groupsBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // ── Groups ──

  List<Group> getGroups() {
    return _groupsBox.values
        .map((v) => Group.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Group? getGroup(String id) {
    final data = _groupsBox.get(id);
    if (data == null) return null;
    return Group.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveGroup(Group group) async {
    await _groupsBox.put(group.id, group.toMap());
  }

  Future<void> deleteGroup(String id) async {
    await _groupsBox.delete(id);
  }

  // ── History ──

  List<HistoryEntry> getHistory() {
    return _historyBox.values
        .map((v) => HistoryEntry.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.shuffledAt.compareTo(a.shuffledAt));
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

  // ── Settings ──

  AppSettings getSettings() {
    final data = _settingsBox.get('settings');
    if (data == null) return AppSettings.defaults();
    return AppSettings.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings.toMap());
  }

  // ── Export / Import ──

  Map<String, dynamic> exportData() {
    return {
      'groups': getGroups().map((g) => g.toMap()).toList(),
      'history': getHistory().map((h) => h.toMap()).toList(),
      'settings': getSettings().toMap(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Backup current data first
    final backup = exportData();

    try {
      await _groupsBox.clear();
      await _historyBox.clear();
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
      if (data['settings'] != null) {
        final settings =
            AppSettings.fromMap(Map<String, dynamic>.from(data['settings'] as Map));
        await saveSettings(settings);
      }
    } catch (e) {
      // Restore from backup on failure
      await importData(backup);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    await _groupsBox.clear();
    await _historyBox.clear();
    await _settingsBox.clear();
  }
}
