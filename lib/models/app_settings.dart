enum ThemeModeOption { system, light, dark }

class AppSettings {
  AppSettings({
    this.themeMode = ThemeModeOption.light,
    this.totalShuffles = 0,
    this.totalCoinTosses = 0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  final ThemeModeOption themeMode;
  final int totalShuffles;
  final int totalCoinTosses;
  final bool soundEnabled;
  final bool hapticEnabled;

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    int? totalShuffles,
    int? totalCoinTosses,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      totalShuffles: totalShuffles ?? this.totalShuffles,
      totalCoinTosses: totalCoinTosses ?? this.totalCoinTosses,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  factory AppSettings.defaults() => AppSettings();

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'totalShuffles': totalShuffles,
      'totalCoinTosses': totalCoinTosses,
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeModeOption.values[map['themeMode'] as int? ?? 1],
      totalShuffles: map['totalShuffles'] as int? ?? 0,
      totalCoinTosses: map['totalCoinTosses'] as int? ?? 0,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      hapticEnabled: map['hapticEnabled'] as bool? ?? true,
    );
  }
}
