import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/app_repository.dart';
import 'repository_provider.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(_repository.getSettings());

  final AppRepository _repository;

  void setThemeMode(ThemeModeOption mode) {
    state = state.copyWith(themeMode: mode);
    _repository.saveSettings(state);
  }

  void incrementShuffles() {
    state = state.copyWith(totalShuffles: state.totalShuffles + 1);
    _repository.saveSettings(state);
  }

  void clearAll() {
    state = AppSettings.defaults();
    _repository.saveSettings(state);
  }

  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(repositoryProvider));
});
