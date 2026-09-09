import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop, foldable }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.foldable,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? foldable;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    if (height > 1000 && width < 700) return ScreenSize.foldable;
    if (width >= 900) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isFoldable = height > 1000 && width < 700;

        if (isFoldable && foldable != null) return foldable!;
        if (width >= 900 && desktop != null) return desktop!;
        if (width >= 600 && tablet != null) return tablet!;
        return mobile;
      },
    );
  }
}

class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(16),
    this.tabletPadding = const EdgeInsets.all(24),
    this.desktopPadding = const EdgeInsets.all(32),
  });

  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets tabletPadding;
  final EdgeInsets desktopPadding;

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    EdgeInsets padding;

    switch (screenSize) {
      case ScreenSize.desktop:
        padding = desktopPadding;
        break;
      case ScreenSize.tablet:
        padding = tabletPadding;
        break;
      default:
        padding = mobilePadding;
    }

    return Padding(padding: padding, child: child);
  }
}
