abstract final class AppConstants {
  static const String appName = 'Shuffle Master';
  static const String appDescription = 'Randomize your list instantly with premium UI and offline support.';

  static const String hiveBoxName = 'shuffle_master_box';
  static const String groupsBox = 'groups';
  static const String historyBox = 'history';
  static const String coinTossBox = 'coin_toss_history';
  static const String settingsBox = 'settings';

  static const int maxGroupSize = 1000;
  static const int defaultGroupSize = 10;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 2);
}
