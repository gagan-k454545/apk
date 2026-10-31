import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Single unified Stats Strip matching Section 5.6 of the Master Prompt:
/// - Radius 22, bg --surface-soft (#FFFCF7), 1px borderSoft, shadowSm, padding 12x8
/// - 4 equal columns separated by 1px vertical dividers (height 32)
/// - Each column: 34px tinted circle + bold 20 count (tabular-nums) + 12px muted label
/// - 600ms ease-out count-up animation on mount!
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final divider = Container(
      width: 1,
      height: 32,
      color: isDark
          ? const Color(0xFF2F3C31)
          : PremiumDesignTokens.borderSoft,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2820) : PremiumDesignTokens.surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334336)
              : PremiumDesignTokens.borderSoft,
        ),
        boxShadow: PremiumDesignTokens.shadowSm,
      ),
      child: Row(
        children: [
          // 1. Names
          Expanded(
            child: _buildStatItem(
              icon: Icons.person_rounded,
              circleTint: isDark
                  ? const Color(0xFF26362A)
                  : PremiumDesignTokens.green100,
              iconColor: PremiumDesignTokens.green700,
              value: totalNames,
              label: 'Names',
              isDark: isDark,
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 2. Groups
          Expanded(
            child: _buildStatItem(
              icon: Icons.groups_rounded,
              circleTint: isDark
                  ? const Color(0xFF382B1E)
                  : PremiumDesignTokens.peach100,
              iconColor: PremiumDesignTokens.orange500,
              value: totalGroups,
              label: 'Groups',
              isDark: isDark,
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 3. Shuffles
          Expanded(
            child: _buildStatItem(
              icon: Icons.shuffle_rounded,
              circleTint: isDark
                  ? const Color(0xFF1E2F33)
                  : PremiumDesignTokens.teal100,
              iconColor: PremiumDesignTokens.teal600,
              value: totalShuffles,
              label: 'Shuffles',
              isDark: isDark,
              reduceMotion: reduceMotion,
            ),
          ),
          divider,

          // 4. Tosses
          Expanded(
            child: _buildStatItem(
              icon: Icons.monetization_on_rounded,
              circleTint: isDark
                  ? const Color(0xFF2B2036)
                  : PremiumDesignTokens.purple100,
              iconColor: PremiumDesignTokens.purple600,
              value: totalCoinTosses,
              label: 'Tosses',
              isDark: isDark,
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
    required bool isDark,
    required bool reduceMotion,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 34px Tinted Circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleTint,
            shape: BoxShape.circle,
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
                      color: isDark
                          ? const Color(0xFFEAF1EB)
                          : PremiumDesignTokens.textStrong,
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
                          color: isDark
                              ? const Color(0xFFEAF1EB)
                              : PremiumDesignTokens.textStrong,
                        ),
                      );
                    },
                  ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFFA2B4A6)
                    : PremiumDesignTokens.textMuted,
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
