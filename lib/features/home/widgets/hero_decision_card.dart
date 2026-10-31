import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The Hero Card matching Section 5.3 & Level 1 Surface Hierarchy:
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, #E3EFDD 100%)
/// - Border: 1px solid rgba(27,67,50,0.12)
/// - Shadow: Two-layer shadow [0 1px 2px rgba(27,67,50,0.06), 0 10px 28px rgba(27,67,50,0.12)]
/// - Eyebrow pill: Solid #FFFFFF, 1px border rgba(27,67,50,0.10), small shadow
/// - Hero Artwork: Scaled up 1.3x (width 195, height 180), anchored bottom-right,
///   all 4 chips (Aarav, Priya, Rahul, Neha) & the 3D bin fully visible inside the card.
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
      constraints: const BoxConstraints(minHeight: 228),
      decoration: BoxDecoration(
        gradient: PremiumDesignTokens.gradHero,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        border: Border.all(
          color: PremiumDesignTokens.cardBorder,
          width: PremiumDesignTokens.cardBorderWidth,
        ),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rXl),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content Column (~54%)
                  Expanded(
                    flex: 54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Level 2 Eyebrow Chip: Solid #FFFFFF + 1px border rgba(27,67,50,0.10) + small shadow
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              PremiumDesignTokens.rPill,
                            ),
                            border: Border.all(
                              color: PremiumDesignTokens.innerBorder,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D1B4332),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
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

                  // Right Artwork Column (~46%) with Scaled 3D Box & Floating Cards
                  Expanded(
                    flex: 46,
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomRight,
                        children: [
                          Positioned(
                            right: -2,
                            bottom: 2,
                            width: 195,
                            height: 182,
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
                                          3.5;
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
          ),
    );
  }
}
