import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static DatabaseService? _instance;
  late Box _generalBox;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Box get generalBox => _generalBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _generalBox = await Hive.openBox(AppConstants.hiveBoxName);
  }

  Future<void> openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  }

  Box getBox(String name) {
    return Hive.box(name);
  }

  Future<void> put(String boxName, dynamic key, dynamic value) async {
    final box = getBox(boxName);
    await box.put(key, value);
  }

  dynamic get(String boxName, dynamic key, {dynamic defaultValue}) {
    final box = getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String boxName, dynamic key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  Future<void> clear(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  List<T> getAll<T>(String boxName) {
    final box = getBox(boxName);
    return box.values.cast<T>().toList();
  }

  Future<void> close() async {
    await Hive.close();
  }

  @visibleForTesting
  Future<void> reset() async {
    _instance = null;
    await Hive.deleteFromDisk();
  }
}
