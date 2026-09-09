enum ThemeModeOption { system, light, dark }

class AppSettings {
  AppSettings({
    this.themeMode = ThemeModeOption.system,
    this.totalShuffles = 0,
  });

  final ThemeModeOption themeMode;
  final int totalShuffles;

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    int? totalShuffles,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      totalShuffles: totalShuffles ?? this.totalShuffles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'totalShuffles': totalShuffles,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeModeOption.values[map['themeMode'] as int? ?? 0],
      totalShuffles: map['totalShuffles'] as int? ?? 0,
    );
  }

  static AppSettings defaults() => AppSettings();
}
