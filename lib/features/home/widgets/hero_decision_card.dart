import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The Hero Banner Card matching Section 5.3 & Level 1 Surface Hierarchy:
/// - Displays the high-fidelity hero banner background with the working 'Get Started' button.
/// - Right-side 3D basket features smooth floating bobbing animation, twinkling sparkle stars,
///   and clean visuals with zero dummy names.
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
    with TickerProviderStateMixin {
  late final AnimationController _basketFloatController;
  late final AnimationController _glassShimmerController;

  @override
  void initState() {
    super.initState();

    // 1. Gentle continuous floating movement animation for the basket
    _basketFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    // 2. Shimmer sheen for the glass Enter button
    _glassShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _basketFloatController.dispose();
    _glassShimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return PressableScale(
      onTap: widget.onGetStarted,
      targetScale: 0.985,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
            width: PremiumDesignTokens.cardBorderWidth,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
          child: AspectRatio(
            aspectRatio: 1672 / 941,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Clean Hero Banner Background (Left Typography & CTA + Right Mint Gradient)
                Image.asset(
                  'assets/images/hero_banner_bg.jpg',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),

                // 2. Interactive "Get Started" CTA Button Zone
                _buildGetStartedButtonZone(),

                // 3. Right Artwork: Floating 3D Basket & Sparkle Stars
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildAnimatedBasketAndArtwork(
                        constraints.maxWidth,
                        constraints.maxHeight,
                        reduceMotion,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Glassmorphic luxury Enter ("Get Started") button zone with frosted glass reflection and shimmer
  Widget _buildGetStartedButtonZone() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Calibrated to 1672x941 banner button bounding box
          final btnLeft = w * 0.0658;
          final btnTop = h * 0.7928;
          final btnWidth = w * (0.3128 - 0.0658);
          final btnHeight = h * (0.9086 - 0.7928);

          return Stack(
            children: [
              Positioned(
                left: btnLeft.clamp(0.0, w),
                top: btnTop.clamp(0.0, h),
                width: btnWidth,
                height: btnHeight,
                child: Semantics(
                  button: true,
                  label: 'Get Started',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedBuilder(
                      animation: _glassShimmerController,
                      builder: (context, _) {
                        final shimmerVal = _glassShimmerController.value;
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              PremiumDesignTokens.rPill,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.50),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x331B4332),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              PremiumDesignTokens.rPill,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // 1. Curved top glass specular reflection arc
                                Positioned(
                                  top: 1.5,
                                  left: 10,
                                  right: 10,
                                  height: 1.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.65),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // 2. Animated diagonal glass sheen sweep
                                Positioned.fill(
                                  child: Transform.translate(
                                    offset: Offset(
                                      -btnWidth + shimmerVal * (btnWidth * 2.5),
                                      0,
                                    ),
                                    child: Transform.rotate(
                                      angle: math.pi / 5,
                                      child: Container(
                                        width: btnWidth * 0.35,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.0),
                                              Colors.white.withValues(alpha: 0.28),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // 3. Material InkWell for ripple and click
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      PremiumDesignTokens.rPill,
                                    ),
                                    splashColor: Colors.white.withValues(alpha: 0.35),
                                    highlightColor: Colors.white.withValues(alpha: 0.20),
                                    hoverColor: Colors.white.withValues(alpha: 0.12),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      widget.onGetStarted();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Right side artwork featuring the floating 3D basket and twinkling sparkle stars (zero dummy names)
  Widget _buildAnimatedBasketAndArtwork(
    double cardWidth,
    double cardHeight,
    bool reduceMotion,
  ) {
    if (reduceMotion) {
      return _buildStaticArtwork(cardWidth, cardHeight);
    }

    return AnimatedBuilder(
      animation: _basketFloatController,
      builder: (context, _) {
        final floatCycle = _basketFloatController.value * math.pi * 2;
        // Continuous smooth vertical floating bob for the 3D basket
        final basketFloatY = math.sin(floatCycle) * 3.5;
        final scale = (cardHeight / 210.0).clamp(0.75, 1.35);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 0. Soft background gradient wash to seamlessly blend right side and obscure any background artifacts
            Positioned(
              left: cardWidth * 0.44,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00F3FAF5),
                      Color(0xCCF3FAF5),
                      Color(0xFFEBF7F0),
                      Color(0xFFE2F4E9),
                    ],
                    stops: [0.0, 0.20, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // 1. Floating 3D Green Basket Body
            Positioned(
              right: cardWidth * 0.05,
              bottom: (cardHeight * 0.02) + basketFloatY,
              width: cardWidth * 0.40,
              height: cardHeight * 0.64,
              child: Image.asset(
                'assets/ui/hero_3d_basket_clean.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),

            // 2. Twinkling magical sparkle star (Top right, warm gold)
            Positioned(
              right: cardWidth * 0.08,
              top: cardHeight * 0.16 + math.sin(floatCycle + 1.0) * 3.0,
              child: _buildSparkleStar(
                size: 16 * scale,
                color: const Color(0xFFF59E0B),
                pulse: 0.85 + math.sin(floatCycle * 2.0) * 0.20,
              ),
            ),

            // 3. Twinkling magical sparkle star (Upper left of basket, rich mint)
            Positioned(
              left: cardWidth * 0.54,
              top: cardHeight * 0.28 + math.sin(floatCycle + 2.5) * 3.2,
              child: _buildSparkleStar(
                size: 13 * scale,
                color: PremiumDesignTokens.green600,
                pulse: 0.80 + math.cos(floatCycle * 2.0) * 0.22,
              ),
            ),

            // 4. Twinkling magical sparkle star (Floating above basket rim, amber)
            Positioned(
              right: cardWidth * 0.26,
              top: cardHeight * 0.10 + math.sin(floatCycle + 4.0) * 3.5,
              child: _buildSparkleStar(
                size: 15 * scale,
                color: const Color(0xFFE6A700),
                pulse: 0.88 + math.sin(floatCycle * 2.2) * 0.18,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Twinkling 4-point sparkle star
  Widget _buildSparkleStar({
    required double size,
    required Color color,
    required double pulse,
  }) {
    return Transform.scale(
      scale: pulse,
      child: Icon(
        Icons.auto_awesome,
        size: size,
        color: color.withValues(alpha: 0.90),
      ),
    );
  }

  /// Static fallback artwork for users with reduced motion enabled
  Widget _buildStaticArtwork(double cardWidth, double cardHeight) {
    final scale = (cardHeight / 210.0).clamp(0.75, 1.35);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: cardWidth * 0.44,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x00F3FAF5),
                  Color(0xCCF3FAF5),
                  Color(0xFFEBF7F0),
                  Color(0xFFE2F4E9),
                ],
                stops: [0.0, 0.20, 0.65, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: cardWidth * 0.05,
          bottom: cardHeight * 0.02,
          width: cardWidth * 0.40,
          height: cardHeight * 0.64,
          child: Image.asset(
            'assets/ui/hero_3d_basket_clean.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned(
          right: cardWidth * 0.08,
          top: cardHeight * 0.16,
          child: _buildSparkleStar(
            size: 16 * scale,
            color: const Color(0xFFF59E0B),
            pulse: 1.0,
          ),
        ),
        Positioned(
          left: cardWidth * 0.54,
          top: cardHeight * 0.28,
          child: _buildSparkleStar(
            size: 13 * scale,
            color: PremiumDesignTokens.green600,
            pulse: 1.0,
          ),
        ),
        Positioned(
          right: cardWidth * 0.26,
          top: cardHeight * 0.10,
          child: _buildSparkleStar(
            size: 15 * scale,
            color: const Color(0xFFE6A700),
            pulse: 1.0,
          ),
        ),
      ],
    );
  }
}
