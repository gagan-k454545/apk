import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The Hero Banner Card matching Section 5.3 & Level 1 Surface Hierarchy:
/// - Displays the high-fidelity hero banner background with the working 'Get Started' button.
/// - Right-side 3D basket features the smooth floating movement animation that was there before.
/// - In-app animations for each individual name ('Gagan', 'Bala', 'Anshu', 'Rakshan', 'vinayaka')
///   coming out of the basket with staggered emergence, independent harmonic floating, and tilts.
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
  late final AnimationController _namesEmergenceController;
  late final AnimationController _glassShimmerController;

  @override
  void initState() {
    super.initState();

    // 1. Gentle continuous floating movement animation for the basket (as before)
    _basketFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    // 2. Cyclic emergence animation for names coming out of the basket
    _namesEmergenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();

    // 3. Shimmer sheen for the glass Enter button
    _glassShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _basketFloatController.dispose();
    _namesEmergenceController.dispose();
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

                // 3. Right Artwork: Floating 3D Basket & Names Coming Out
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildAnimatedBasketAndNames(
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

  /// Right side artwork featuring the floating 3D basket and individual animated name chips
  Widget _buildAnimatedBasketAndNames(
    double cardWidth,
    double cardHeight,
    bool reduceMotion,
  ) {
    if (reduceMotion) {
      return _buildStaticArtwork(cardWidth, cardHeight);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _basketFloatController,
        _namesEmergenceController,
      ]),
      builder: (context, _) {
        final floatCycle = _basketFloatController.value * math.pi * 2;
        // The original gentle floating movement animation for the basket
        final basketFloatY = math.sin(floatCycle) * 3.5;

        // Progress for cyclic emergence of names coming out of the basket
        final cycleProgress = _namesEmergenceController.value;

        // Helper to calculate staggered emergence and harmonic bobbing for each name
        double getChipEmergence(double start, double end) {
          if (cycleProgress < start) return 0.0;
          if (cycleProgress > end) {
            // Once fully emerged, stay out with subtle organic wave
            final extraT = (cycleProgress - end) / (1.0 - end);
            return 1.0 - (math.sin(extraT * math.pi * 2) * 0.04);
          }
          final t = (cycleProgress - start) / (end - start);
          return Curves.easeOutBack.transform(t);
        }

        // Each individual name has divided emergence curve & independent floating harmonic
        final gaganEmerge = getChipEmergence(0.18, 0.48);
        final balaEmerge = getChipEmergence(0.14, 0.44);
        final anshuEmerge = getChipEmergence(0.08, 0.38);
        final rakshanEmerge = getChipEmergence(0.04, 0.32);
        final vinayakaEmerge = getChipEmergence(0.00, 0.26);

        // Independent bobbing waves for each distinct name
        final floatGagan = math.sin(floatCycle + 0.0) * 4.5;
        final floatBala = math.sin(floatCycle + 1.2) * 4.0;
        final floatAnshu = math.sin(floatCycle + 2.4) * 4.8;
        final floatRakshan = math.sin(floatCycle + 3.6) * 4.2;
        final floatVinayaka = math.sin(floatCycle + 4.8) * 3.6;

        // Scaling factor relative to card height
        final scale = (cardHeight / 210.0).clamp(0.75, 1.35);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Background Name Chips (Emerging from inside & behind basket lip) ──

            // 1. GAGAN (peach chip, rotated -11°)
            _buildAnimatedChip(
              name: 'Gagan',
              bg: const Color(0xFFFED8B6),
              textColor: const Color(0xFF3B1E08),
              left: cardWidth * 0.585,
              restTop: cardHeight * 0.175,
              basketTop: cardHeight * 0.50,
              angle: -11.0 * math.pi / 180,
              emergence: gaganEmerge,
              floatY: floatGagan + (basketFloatY * 0.4),
              scale: scale,
            ),

            // 2. BALA (white chip, rotated +9°)
            _buildAnimatedChip(
              name: 'Bala',
              bg: Colors.white,
              textColor: const Color(0xFF1B4332),
              left: cardWidth * 0.745,
              restTop: cardHeight * 0.200,
              basketTop: cardHeight * 0.52,
              angle: 9.0 * math.pi / 180,
              emergence: balaEmerge,
              floatY: floatBala + (basketFloatY * 0.4),
              scale: scale,
              hasBorderGlow: true,
            ),

            // 3. ANSHU (soft sage/mint chip, rotated -6°)
            _buildAnimatedChip(
              name: 'Anshu',
              bg: const Color(0xFFD6EBD7),
              textColor: const Color(0xFF14382A),
              left: cardWidth * 0.615,
              restTop: cardHeight * 0.325,
              basketTop: cardHeight * 0.54,
              angle: -6.0 * math.pi / 180,
              emergence: anshuEmerge,
              floatY: floatAnshu + (basketFloatY * 0.4),
              scale: scale,
            ),

            // 4. RAKSHAN (warm cream chip, rotated +5°)
            _buildAnimatedChip(
              name: 'Rakshan',
              bg: const Color(0xFFFEECC7),
              textColor: const Color(0xFF3B1E08),
              left: cardWidth * 0.735,
              restTop: cardHeight * 0.355,
              basketTop: cardHeight * 0.55,
              angle: 5.0 * math.pi / 180,
              emergence: rakshanEmerge,
              floatY: floatRakshan + (basketFloatY * 0.4),
              scale: scale,
            ),

            // ── 3D Green Basket Body with movement animation (as before) ──
            Positioned(
              right: cardWidth * 0.04,
              bottom: (cardHeight * 0.01) + basketFloatY,
              width: cardWidth * 0.38,
              height: cardHeight * 0.54,
              child: Image.asset(
                'assets/ui/hero_3d_basket_clean.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),

            // ── Foreground Name Chip: VINAYAKA (peeking out right from the front rim) ──
            _buildAnimatedChip(
              name: 'vinayaka',
              bg: const Color(0xFFE5F5E5),
              textColor: const Color(0xFF14382A),
              left: cardWidth * 0.675,
              restTop: cardHeight * 0.470,
              basketTop: cardHeight * 0.58,
              angle: -2.0 * math.pi / 180,
              emergence: vinayakaEmerge,
              floatY: floatVinayaka + (basketFloatY * 0.8),
              scale: scale,
            ),
          ],
        );
      },
    );
  }

  /// Individual animated name chip with emergence translation, float wave, and angle
  Widget _buildAnimatedChip({
    required String name,
    required Color bg,
    required Color textColor,
    required double left,
    required double restTop,
    required double basketTop,
    required double angle,
    required double emergence,
    required double floatY,
    required double scale,
    bool hasBorderGlow = false,
  }) {
    // Current interpolated Y coordinate: emerges out from basketTop up to restTop
    final currentTop = (basketTop + (restTop - basketTop) * emergence) + floatY;
    final currentScale = (0.75 + (0.25 * emergence)) * scale;
    final opacity = emergence.clamp(0.1, 1.0);

    return Positioned(
      left: left,
      top: currentTop,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: currentScale,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4.5,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasBorderGlow
                      ? const Color(0x241B4332)
                      : Colors.white.withValues(alpha: 0.85),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F1B4332), // 0 5px 12px rgba(27,67,50,0.12)
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Static fallback artwork for users with reduced motion enabled
  Widget _buildStaticArtwork(double cardWidth, double cardHeight) {
    final scale = (cardHeight / 210.0).clamp(0.75, 1.35);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAnimatedChip(
          name: 'Gagan',
          bg: const Color(0xFFFED8B6),
          textColor: const Color(0xFF3B1E08),
          left: cardWidth * 0.585,
          restTop: cardHeight * 0.175,
          basketTop: cardHeight * 0.175,
          angle: -11.0 * math.pi / 180,
          emergence: 1.0,
          floatY: 0,
          scale: scale,
        ),
        _buildAnimatedChip(
          name: 'Bala',
          bg: Colors.white,
          textColor: const Color(0xFF1B4332),
          left: cardWidth * 0.745,
          restTop: cardHeight * 0.200,
          basketTop: cardHeight * 0.200,
          angle: 9.0 * math.pi / 180,
          emergence: 1.0,
          floatY: 0,
          scale: scale,
          hasBorderGlow: true,
        ),
        _buildAnimatedChip(
          name: 'Anshu',
          bg: const Color(0xFFD6EBD7),
          textColor: const Color(0xFF14382A),
          left: cardWidth * 0.615,
          restTop: cardHeight * 0.325,
          basketTop: cardHeight * 0.325,
          angle: -6.0 * math.pi / 180,
          emergence: 1.0,
          floatY: 0,
          scale: scale,
        ),
        _buildAnimatedChip(
          name: 'Rakshan',
          bg: const Color(0xFFFEECC7),
          textColor: const Color(0xFF3B1E08),
          left: cardWidth * 0.735,
          restTop: cardHeight * 0.355,
          basketTop: cardHeight * 0.355,
          angle: 5.0 * math.pi / 180,
          emergence: 1.0,
          floatY: 0,
          scale: scale,
        ),
        Positioned(
          right: cardWidth * 0.04,
          bottom: cardHeight * 0.01,
          width: cardWidth * 0.38,
          height: cardHeight * 0.54,
          child: Image.asset(
            'assets/ui/hero_3d_basket_clean.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        _buildAnimatedChip(
          name: 'vinayaka',
          bg: const Color(0xFFE5F5E5),
          textColor: const Color(0xFF14382A),
          left: cardWidth * 0.675,
          restTop: cardHeight * 0.470,
          basketTop: cardHeight * 0.470,
          angle: -2.0 * math.pi / 180,
          emergence: 1.0,
          floatY: 0,
          scale: scale,
        ),
      ],
    );
  }
}
