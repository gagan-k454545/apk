import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;
  bool get isFoldable => screenHeight > 1000 && screenWidth < 700;

  double responsive({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, void>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);

  ScaffoldMessengerState get scaffoldMessenger =>
      ScaffoldMessenger.of(this);

  void showAppSnackBar(String message, {bool isError = false}) {
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get sentenceCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

extension DurationExtensions on Duration {
  String get formatted {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    if (minutes > 0) {
      return '$minutes m ${seconds.toString().padLeft(2, '0')} s';
    }
    return '$seconds s';
  }
}

extension ListExtensions<T> on List<T> {
  List<T> shuffleCustom() {
    final list = List<T>.from(this);
    list.shuffle();
    return list;
  }

  T get random {
    if (isEmpty) throw StateError('Cannot get random element from empty list');
    return this[DateTime.now().microsecondsSinceEpoch % length];
  }
}
