import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';
import 'shared_accent_chip.dart';

/// The prominent Hero Card on the Shuffle Master home screen.
/// Features:
/// - "🚀 MAKE DECISIONS EASIER" pill
/// - Editorial "Shuffle, Pick and Decide" title
/// - Descriptive subtitle
/// - "Get Started ->" tactile action button
/// - 3D green box holding floating name cards ("Aarav", "Priya", "Rahul", "Neha")
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
      duration: const Duration(seconds: 4),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF263327),
                  Color(0xFF1E2620),
                ]
              : const [
                  Color(0xFFFBF4EA),
                  Color(0xFFF1E6D4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF354437) : const Color(0xFFE9DEC8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C2E4634),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill Chip
              SharedAccentChip(
                label: 'MAKE DECISIONS EASIER',
                iconWidget: const Text('🚀', style: TextStyle(fontSize: 11)),
                backgroundColor: isDark
                    ? const Color(0xFF362C1E)
                    : PremiumDesignTokens.softPeach,
                textColor: const Color(0xFF8C5325),
                borderColor: const Color(0xFFEEDDCE),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
              const SizedBox(height: 12),

              // Title
              SizedBox(
                width: 185,
                child: Text(
                  'Shuffle,\nPick and\nDecide',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                    height: 1.15,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              SizedBox(
                width: 175,
                child: Text(
                  'Create groups, shuffle names, toss a coin and make fair decisions in seconds.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // "Get Started ->" Button
              PressableScale(
                onTap: widget.onGetStarted,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumDesignTokens.mossDark,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x301E3A2B),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3D Card Box Illustration on Right
          Positioned(
            right: 0,
            bottom: 0,
            top: 4,
            child: _buildHeroCardsIllustration(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCardsIllustration(bool isDark) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 3.5;

        return SizedBox(
          width: 140,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Confetti / Sparkle Accents
              Positioned(
                top: 6 + floatOffset,
                right: 32,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD67E2D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 44 - floatOffset,
                left: 12,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF456B52),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 18 - floatOffset,
                left: 36,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Container(
                    width: 7,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE89A38),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Green container 3D box
              Positioned(
                bottom: 4,
                child: Container(
                  width: 115,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2C553C),
                        Color(0xFF1E3A2B),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x281E3A2B),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shuffle_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // Floating mini cards with gentle floating offsets
              Positioned(
                top: 10 + floatOffset,
                left: 8,
                child: _buildMiniNameCard('Aarav', const Color(0xFFFBE4D2)),
              ),
              Positioned(
                top: 22 - floatOffset,
                right: 4,
                child: _buildMiniNameCard('Priya', const Color(0xFFFBF4EA)),
              ),
              Positioned(
                top: 46 + floatOffset * 0.7,
                left: 14,
                child: _buildMiniNameCard('Rahul', const Color(0xFFE5EDE3)),
              ),
              Positioned(
                top: 56 - floatOffset * 0.8,
                right: 12,
                child: _buildMiniNameCard('Neha', const Color(0xFFF5E6C8)),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildMiniNameCard(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF233629),
        ),
      ),
    );
  }
}
