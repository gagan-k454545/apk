import 'package:flutter/material.dart';

/// Centralized Design Tokens strictly matching Section 4.2 of the Master Prompt.
/// Semantic Color Coding:
/// - Green = Shuffle / primary / names
/// - Orange-gold = Coin Toss
/// - Teal = Groups
/// - Purple = History
abstract final class PremiumDesignTokens {
  // ── Backgrounds ──
  static const Color bgApp = Color(0xFFFBF6EE); // warm cream page background
  static const Color bgAppGlow = Color(0xFFFCEBDD); // faint peach glow, bottom/side
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFFFFCF7); // stats strip, group cards, nav
  static const Color background = bgApp;
  static const Color surfaceTinted = Color(0xFFF8F4EC);
  static const Color pedestal = Color(0xFFF4EDE2);

  // ── Brand Greens ──
  static const Color green900 = Color(0xFF14382A);
  static const Color green800 = Color(0xFF1B4332); // primary button, active nav, FAB
  static const Color green700 = Color(0xFF245A43);
  static const Color green600 = Color(0xFF2E6B4E); // "Master" wordmark, "Decide" word
  static const Color green500 = Color(0xFF4F8A6A);
  static const Color green300 = Color(0xFFA9C9B2);
  static const Color green200 = Color(0xFFCFE0CB); // sage chip ("Rahul")
  static const Color green100 = Color(0xFFE6F0E3); // mint tint
  static const Color green50 = Color(0xFFF0F6EC);

  // ── Peach / Orange (Coin Toss) ──
  static const Color peach50 = Color(0xFFFFF3EA);
  static const Color peach100 = Color(0xFFFDE6D6);
  static const Color peach200 = Color(0xFFF9D3BA); // name chips ("Aarav")
  static const Color orange500 = Color(0xFFF28C28);
  static const Color orange400 = Color(0xFFF6A53F);
  static const Color gold300 = Color(0xFFF2C75C);
  static const Color gold500 = Color(0xFFD99A22); // coin rim

  // ── Teal (Groups) ──
  static const Color teal50 = Color(0xFFE3F2F1);
  static const Color teal100 = Color(0xFFD2EBEA);
  static const Color teal600 = Color(0xFF2A8C99);
  static const Color teal700 = Color(0xFF1F7280);

  // ── Purple (History) ──
  static const Color purple50 = Color(0xFFF0ECFB);
  static const Color purple100 = Color(0xFFE6DFF8);
  static const Color purple600 = Color(0xFF7B5CD6);
  static const Color purple700 = Color(0xFF6444BF);

  // ── Text ──
  static const Color textStrong = Color(0xFF14231C); // headings (near-black, green undertone)
  static const Color textBody = Color(0xFF4B5550);
  static const Color textMuted = Color(0xFF7A817C); // captions, inactive nav
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Lines & Borders ──
  static const Color borderSoft = Color(0x1414382A); // rgba(20, 56, 42, 0.08)
  static const Color borderGlass = Color(0xB2FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color hairline = Color(0xFFE8E2D5);

  // ── Backward Compatibility Aliases ──
  static const Color mossDark = green800;
  static const Color mossPrimary = green600;
  static const Color sageMedium = green500;
  static const Color sageLight = green100;
  static const Color sageBorder = green300;
  static const Color sageText = green900;
  static const Color warmBeige = peach50;
  static const Color softPeach = peach100;
  static const Color peachBorder = Color(0xFFEEDDCE);
  static const Color peachAccent = orange500;
  static const Color gold = gold500;
  static const Color goldLight = gold300;
  static const Color goldBorder = Color(0xFFE8CF96);
  static const Color goldText = Color(0xFF7E540C);
  static const Color textPrimary = textStrong;
  static const Color textSecondary = textBody;

  // ── Radii ──
  static const double rXs = 10.0;
  static const double rSm = 14.0;
  static const double rMd = 18.0;
  static const double rLg = 24.0;
  static const double rXl = 28.0;
  static const double rPill = 999.0;

  static const double radiusSm = rSm;
  static const double radiusMd = rMd;
  static const double radiusLg = rLg;
  static const double radiusXl = rXl;
  static const double radiusHero = 26.0;
  static const double radiusPill = rPill;

  // ── Spacing (4px base) ──
  static const double sp1 = 4.0;
  static const double sp2 = 8.0;
  static const double sp3 = 12.0;
  static const double sp4 = 16.0;
  static const double sp5 = 20.0;
  static const double sp6 = 24.0;
  static const double sp8 = 32.0;

  static const double spacingXs = sp1;
  static const double spacingSm = sp2;
  static const double spacingMd = sp3;
  static const double spacingLg = sp4;
  static const double spacingXl = sp5;
  static const double spacingXxl = sp6;
  static const double spacingHero = sp8;

  // ── Shadows ──
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x101B4332), // rgba(27, 67, 50, 0.06)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A1B4332), // rgba(27, 67, 50, 0.10)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x281B4332), // rgba(27, 67, 50, 0.16)
      blurRadius: 40,
      offset: Offset(0, 18),
    ),
  ];

  static const List<BoxShadow> shadowPeach = [
    BoxShadow(
      color: Color(0x2EF28C28), // rgba(242, 140, 40, 0.18)
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x471B4332), // rgba(27, 67, 50, 0.28)
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> softCardShadow = shadowSm;
  static const List<BoxShadow> buttonShadow = shadowButton;

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

  // ── Gradients ──
  static const LinearGradient gradPrimary = LinearGradient(
    colors: [Color(0xFF2F6B4F), Color(0xFF1B4332)],
    begin: Alignment(-0.6, -0.8),
    end: Alignment(0.6, 0.8),
  );

  static const LinearGradient gradHero = LinearGradient(
    colors: [
      Color(0xFFE4EFE0),
      Color(0xFFF3F4E6),
      Color(0xFFFBF1E4),
    ],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradMintCard = LinearGradient(
    colors: [Color(0xFFE6F0E3), Color(0xFFF6F8EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradPeachCard = LinearGradient(
    colors: [Color(0xFFFDE6D6), Color(0xFFFFF4EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradOrange = LinearGradient(
    colors: [Color(0xFFF6A53F), Color(0xFFF28C28)],
    begin: Alignment(-0.6, -0.8),
    end: Alignment(0.6, 0.8),
  );

  static const LinearGradient gradTeal = LinearGradient(
    colors: [Color(0xFF34A0AD), Color(0xFF1F7280)],
    begin: Alignment(-0.6, -0.8),
    end: Alignment(0.6, 0.8),
  );

  static const LinearGradient gradPurple = LinearGradient(
    colors: [Color(0xFF8F73E6), Color(0xFF6444BF)],
    begin: Alignment(-0.6, -0.8),
    end: Alignment(0.6, 0.8),
  );

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
