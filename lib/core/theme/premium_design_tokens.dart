import 'package:flutter/material.dart';

/// Centralized Design Tokens for the Premium Cream & Olive Theme.
/// Extracted directly from the visual reference image:
/// - Soft warm cream base
/// - Muted forest & moss greens
/// - Subtle warm gold & champagne accents
/// - Pale peach & warm beige highlights
abstract final class PremiumDesignTokens {
  // ── Colors ──
  static const Color background = Color(0xFFFBF9F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTinted = Color(0xFFF8F4EC);
  static const Color pedestal = Color(0xFFF4EDE2);

  static const Color mossDark = Color(0xFF1E3A2B);
  static const Color mossPrimary = Color(0xFF244835);
  static const Color sageMedium = Color(0xFF456B52);
  static const Color sageLight = Color(0xFFEAF1E9);
  static const Color sageBorder = Color(0xFFD0E0CE);
  static const Color sageText = Color(0xFF1F3D27);

  static const Color warmBeige = Color(0xFFF6ECE1);
  static const Color softPeach = Color(0xFFFBF3EB);
  static const Color peachBorder = Color(0xFFEEDDCE);
  static const Color peachAccent = Color(0xFFB86A38);

  static const Color gold = Color(0xFFD69A2D);
  static const Color goldLight = Color(0xFFFDF7E7);
  static const Color goldBorder = Color(0xFFE8CF96);
  static const Color goldText = Color(0xFF7E540C);

  static const Color textPrimary = Color(0xFF1A2A20);
  static const Color textSecondary = Color(0xFF5A6C60);
  static const Color textMuted = Color(0xFF88998C);
  static const Color hairline = Color(0xFFE8E2D5);

  // ── Spacing Rhythm ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingHero = 32.0;

  // ── Radii ──
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 22.0;
  static const double radiusHero = 26.0;
  static const double radiusPill = 28.0;

  // ── Shadows ──
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x061E3A2B),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> winnerGlowShadow = [
    BoxShadow(
      color: Color(0x24D69A2D),
      blurRadius: 20,
      spreadRadius: 1,
      offset: Offset(0, 5),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> heroGlowShadow = [
    BoxShadow(
      color: Color(0x351E3A2B),
      blurRadius: 28,
      spreadRadius: 2,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x281E3A2B),
      blurRadius: 16,
      offset: Offset(0, 5),
    ),
  ];

  // ── Durations ──
  static const Duration durationQuick = Duration(milliseconds: 120);
  static const Duration durationFeedback = Duration(milliseconds: 160);
  static const Duration durationTransition = Duration(milliseconds: 200);
  static const Duration durationEntrance = Duration(milliseconds: 220);
  static const Duration durationCelebration = Duration(milliseconds: 850);

  // ── Easing Curves ──
  static const Curve easeOutCubic = Cubic(0.23, 1.0, 0.32, 1.0);
  static const Curve easeDrawer = Cubic(0.32, 0.72, 0.0, 1.0);
}
