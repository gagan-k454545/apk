import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The Hero Card matching Section 5.3 of the Master Prompt:
/// - Min-height ~222px, radius 28, gradHero, borderSoft, shadowMd
/// - Eyebrow pill: Sparkles icon + "MAKE DECISIONS EASIER"
/// - Headline (Playfair Display 800): "Shuffle,\nPick and\nDecide" (Decide in --green-600)
/// - Body: "Create groups, shuffle names, toss a coin and make fair decisions in seconds."
/// - CTA button "Get Started →" (radius pill, gradPrimary, shadowButton)
/// - 3D sage-green open box with embossed shuffle icon, inner rim, contact shadow
/// - 4 floating tilted name chips (Aarav -18°, Priya 12°, Rahul 18°, Neha 8°)
/// - Staggered floating micro-animation + confetti sparks (disabled on reduced motion)
class HeroDecisionCard extends StatefulWidget {
  const HeroDecisionCard({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  State<HeroDecisionCard> createState() => _HeroDecisionCardState();
}

class _HeroDecisionCardState extends State<HeroDecisionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 380;
    final headlineSize = isNarrow ? 32.0 : 36.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 222),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF243226), Color(0xFF1B241C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : PremiumDesignTokens.gradHero,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334336)
              : PremiumDesignTokens.borderSoft,
        ),
        boxShadow: PremiumDesignTokens.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative subtle organic background ambient glows
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDesignTokens.green100.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 20,
              child: Container(
                width: 180,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDesignTokens.peach100.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Layout
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content Column (~55%)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Eyebrow Chip (11/14 uppercase, tracking +0.8)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E3D30)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(
                              PremiumDesignTokens.rPill,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3B4F3E)
                                  : PremiumDesignTokens.borderSoft,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: PremiumDesignTokens.orange500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'MAKE DECISIONS EASIER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: isDark
                                      ? const Color(0xFFBACDBF)
                                      : PremiumDesignTokens.textBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Editorial Headline in Playfair Display 800
                        RichText(
                          text: TextSpan(
                            text: 'Shuffle,\nPick and\n',
                            style: AppTypography.heroHeadline(
                              fontSize: headlineSize,
                              color: isDark
                                  ? const Color(0xFFEAF1EB)
                                  : PremiumDesignTokens.textStrong,
                            ),
                            children: [
                              TextSpan(
                                text: 'Decide',
                                style: AppTypography.heroHeadline(
                                  fontSize: headlineSize,
                                  color: PremiumDesignTokens.green600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Body description
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 195),
                          child: Text(
                            'Create groups, shuffle names, toss a coin and make fair decisions in seconds.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: isDark
                                  ? const Color(0xFFA2B4A6)
                                  : PremiumDesignTokens.textBody,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CTA Button "Get Started →"
                        PressableScale(
                          onTap: widget.onGetStarted,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: PremiumDesignTokens.gradPrimary,
                              borderRadius: BorderRadius.circular(
                                PremiumDesignTokens.rPill,
                              ),
                              boxShadow: PremiumDesignTokens.shadowButton,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Artwork Column (~45%)
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 220,
                      child: reduceMotion
                          ? _buildStaticArtwork(isDark)
                          : AnimatedBuilder(
                              animation: _floatController,
                              builder: (context, _) =>
                                  _buildAnimatedArtwork(isDark),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticArtwork(bool isDark) {
    return _buildIllustration(0, 0, 0, 0, 1.0, isDark);
  }

  Widget _buildAnimatedArtwork(bool isDark) {
    final t = _floatController.value;
    final float1 = math.sin(t * math.pi * 2) * 4.0;
    final float2 = math.cos(t * math.pi * 2) * 3.5;
    final float3 = math.sin((t + 0.3) * math.pi * 2) * 3.8;
    final float4 = math.cos((t + 0.5) * math.pi * 2) * 4.2;
    final breath = 1.0 + (math.sin(t * math.pi * 2) * 0.015);

    return _buildIllustration(float1, float2, float3, float4, breath, isDark);
  }

  Widget _buildIllustration(
    double f1,
    double f2,
    double f3,
    double f4,
    double boxScale,
    bool isDark,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Confetti rounded dashes
        Positioned(
          top: 8 + f1,
          left: 10,
          child: Transform.rotate(
            angle: -0.4,
            child: Container(
              width: 8,
              height: 3,
              decoration: BoxDecoration(
                color: PremiumDesignTokens.orange500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Positioned(
          top: 24 + f2,
          right: 18,
          child: Transform.rotate(
            angle: 0.6,
            child: Container(
              width: 7,
              height: 3,
              decoration: BoxDecoration(
                color: PremiumDesignTokens.green500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50 + f3,
          left: 4,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: PremiumDesignTokens.gold500,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // 3D Sage-green box container with inner rim & embossed shuffle icon
        Positioned(
          bottom: 2,
          right: 0,
          left: 4,
          child: Transform.scale(
            scale: boxScale,
            child: _build3DBox(isDark),
          ),
        ),

        // Floating Name Chips:
        // Aarav (peach -18°), Priya (cream 12°), Rahul (sage 18°), Neha (peach-pink 8°)
        Positioned(
          top: 14 + f1,
          left: 0,
          child: Transform.rotate(
            angle: -18 * math.pi / 180,
            child: _buildNameChip(
              'Aarav',
              PremiumDesignTokens.peach200,
              const Color(0xFF4A2A14),
            ),
          ),
        ),
        Positioned(
          top: 26 + f2,
          right: 10,
          child: Transform.rotate(
            angle: 12 * math.pi / 180,
            child: _buildNameChip(
              'Priya',
              const Color(0xFFFFF9F2),
              PremiumDesignTokens.textStrong,
            ),
          ),
        ),
        Positioned(
          top: 56 + f3,
          left: 14,
          child: Transform.rotate(
            angle: 18 * math.pi / 180,
            child: _buildNameChip(
              'Rahul',
              PremiumDesignTokens.green200,
              PremiumDesignTokens.green900,
            ),
          ),
        ),
        Positioned(
          top: 66 + f4,
          right: 16,
          child: Transform.rotate(
            angle: 8 * math.pi / 180,
            child: _buildNameChip(
              'Neha',
              PremiumDesignTokens.peach100,
              const Color(0xFF5A2A14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DBox(bool isDark) {
    return Container(
      width: 126,
      height: 82,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3F6B53),
            Color(0xFF1E3A2B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3514382A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF7FA58A).withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner rim top highlight ellipse
          Positioned(
            top: 4,
            left: 10,
            right: 10,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Embossed White Shuffle Icon on the front face
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.shuffle_rounded,
                size: 34,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameChip(String name, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1B4332), // 0 6px 12px rgba(27,67,50,.12)
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
