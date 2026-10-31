import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The Hero Card matching Section 5.3 & Requirement 2:
/// - Min-height ~222px, radius 28, gradHero, borderSoft, shadowMd
/// - Eyebrow pill: Sparkles icon + "MAKE DECISIONS EASIER"
/// - Headline (Playfair Display 800): "Shuffle,\nPick and\nDecide" (Decide in --green-600)
/// - Body: "Create groups, shuffle names, toss a coin and make fair decisions in seconds."
/// - CTA button "Get Started →" (radius pill, gradPrimary, shadowButton)
/// - The real 3D sage-green open bin with floating name chips (Aarav, Priya, Rahul, Neha)
///   CROPPED FROM THE REFERENCE IMAGE, with gentle float animation, bleeding off bottom-right.
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
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 380;
    final headlineSize = isNarrow ? 32.0 : 36.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 222),
      decoration: BoxDecoration(
        gradient: PremiumDesignTokens.gradHero,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        border: Border.all(
          color: PremiumDesignTokens.borderSoft,
        ),
        boxShadow: PremiumDesignTokens.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative subtle organic ambient glows
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
                        // Eyebrow Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(
                              PremiumDesignTokens.rPill,
                            ),
                            border: Border.all(
                              color: PremiumDesignTokens.borderSoft,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: PremiumDesignTokens.orange500,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'MAKE DECISIONS EASIER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: PremiumDesignTokens.textBody,
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
                              color: PremiumDesignTokens.textStrong,
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
                          child: const Text(
                            'Create groups, shuffle names, toss a coin and make fair decisions in seconds.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: PremiumDesignTokens.textBody,
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

                  // Right Artwork Column (~45%) with Cropped 3D Box & Floating Cards
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            right: -14,
                            bottom: -10,
                            width: 175,
                            height: 175,
                            child: reduceMotion
                                ? Image.asset(
                                    'assets/ui/hero-shuffle-box.png',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  )
                                : AnimatedBuilder(
                                    animation: _floatController,
                                    builder: (context, child) {
                                      final floatY = math.sin(
                                              _floatController.value *
                                                  math.pi *
                                                  2) *
                                          4.0;
                                      return Transform.translate(
                                        offset: Offset(0, floatY),
                                        child: child,
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/ui/hero-shuffle-box.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                          ),
                        ],
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
}
