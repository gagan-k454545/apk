import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Single unified Stats Strip matching Section 5.6 & Level 1 Surface Hierarchy:
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, #FBF7F0 100%)
/// - Border: 1px solid rgba(27,67,50,0.12)
/// - Shadow: Two-layer shadow [0 1px 2px rgba(27,67,50,0.06), 0 10px 28px rgba(27,67,50,0.12)]
/// - 4 equal columns separated by 1px vertical dividers (height 32)
/// - Count-up animation on mount
class StatsStrip extends StatelessWidget {
  const StatsStrip({
    super.key,
    required this.totalNames,
    required this.totalGroups,
    required this.totalShuffles,
    required this.totalCoinTosses,
  });

  final int totalNames;
  final int totalGroups;
  final int totalShuffles;
  final int totalCoinTosses;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final divider = Container(
      width: 1,
      height: 32,
      color: PremiumDesignTokens.cardBorder,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: PremiumDesignTokens.gradNeutralCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: PremiumDesignTokens.cardBorder,
          width: PremiumDesignTokens.cardBorderWidth,
        ),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      child: Row(
        children: [
          // 1. Names
          Expanded(
            child: _buildStatItem(
              icon: Icons.person_rounded,
              circleTint: PremiumDesignTokens.green100,
              iconColor: PremiumDesignTokens.green700,
              value: totalNames,
              label: 'Names',
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 2. Groups
          Expanded(
            child: _buildStatItem(
              icon: Icons.groups_rounded,
              circleTint: PremiumDesignTokens.peach100,
              iconColor: PremiumDesignTokens.orange500,
              value: totalGroups,
              label: 'Groups',
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 3. Shuffles
          Expanded(
            child: _buildStatItem(
              icon: Icons.shuffle_rounded,
              circleTint: PremiumDesignTokens.teal100,
              iconColor: PremiumDesignTokens.teal600,
              value: totalShuffles,
              label: 'Shuffles',
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 4. Tosses
          Expanded(
            child: _buildStatItem(
              icon: Icons.monetization_on_rounded,
              circleTint: PremiumDesignTokens.purple100,
              iconColor: PremiumDesignTokens.purple600,
              value: totalCoinTosses,
              label: 'Tosses',
              reduceMotion: reduceMotion,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color circleTint,
    required Color iconColor,
    required int value,
    required String label,
    required bool reduceMotion,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 32px Tinted Circle with soft border
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleTint,
            shape: BoxShape.circle,
            border: Border.all(
              color: PremiumDesignTokens.innerBorder,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Stack: Number + Label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            reduceMotion
                ? Text(
                    '$value',
                    style: AppTypography.statNumber(
                      color: PremiumDesignTokens.textStrong,
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: value.toDouble()),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedVal, _) {
                      return Text(
                        '${animatedVal.round()}',
                        style: AppTypography.statNumber(
                          color: PremiumDesignTokens.textStrong,
                        ),
                      );
                    },
                  ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: PremiumDesignTokens.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Backward compatibility alias
typedef StatTile = StatsStrip;
