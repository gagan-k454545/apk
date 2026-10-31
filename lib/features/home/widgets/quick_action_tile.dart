import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Quick Action Tile matching Section 5.5 of the Master Prompt:
/// - Radius 20, height ~72, padding 8, column-centered
/// - 34x34 icon tile (radius 11) with gradient
/// - 12px label in --text-strong
/// - 1px borderGlass, shadowSm, tactile scale down (.96)
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.backgroundGradient,
    required this.iconTileGradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Gradient iconTileGradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PressableScale(
      onTap: onTap,
      targetScale: 0.96,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222E26) : null,
          gradient: isDark ? null : backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334336)
                : PremiumDesignTokens.borderGlass,
          ),
          boxShadow: PremiumDesignTokens.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 34 x 34 Icon Tile
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: iconTileGradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 4,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // 12px Label
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFEAF1EB)
                    : PremiumDesignTokens.textStrong,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
