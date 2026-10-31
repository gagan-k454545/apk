import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Quick Action Tile matching Section 5.5 & Level 1 Surface Hierarchy:
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, #FBF7F0 100%)
/// - Border: 1px solid rgba(27,67,50,0.12)
/// - Shadow: 0 1px 2px rgba(27,67,50,0.06), 0 10px 28px rgba(27,67,50,0.12)
/// - Saturated gradient icon tile + 12px label in --text-strong
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
    return PressableScale(
      onTap: onTap,
      targetScale: 0.96,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          gradient: backgroundGradient ?? PremiumDesignTokens.gradNeutralCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
            width: PremiumDesignTokens.cardBorderWidth,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 34 x 34 Saturated Gradient Icon Tile
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: iconTileGradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
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

            // 12px Label in --text-strong
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PremiumDesignTokens.textStrong,
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
