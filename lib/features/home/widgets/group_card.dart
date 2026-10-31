import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Reusable Group Card matching Section 5.7 & Level 1 Surface Hierarchy:
/// - 124px wide, height 94px, radius 18
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, #FBF7F0 100%)
/// - Border: 1px solid rgba(27,67,50,0.12)
/// - Shadow: Two-layer shadow [0 1px 2px rgba(27,67,50,0.06), 0 10px 28px rgba(27,67,50,0.12)]
/// - Top-left: 30x30 icon tile with visible border
/// - Spacer for vertical breathing room
/// - Bottom: Group name (13/600) + "12 names" (11/400 muted)
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.name,
    required this.memberCount,
    required this.icon,
    required this.iconTileBg,
    required this.iconColor,
    required this.onTap,
    this.onMenuTap,
  });

  final String name;
  final int memberCount;
  final IconData icon;
  final Color iconTileBg;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      targetScale: 0.96,
      child: Container(
        width: 126,
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: PremiumDesignTokens.gradNeutralCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
            width: PremiumDesignTokens.cardBorderWidth,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: 30x30 Icon Tile + Kebab Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconTileBg,
                    borderRadius: BorderRadius.circular(10),
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
                GestureDetector(
                  onTap: onMenuTap,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Bottom Labels: Group Name + Member Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: PremiumDesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$memberCount names',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: PremiumDesignTokens.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state dashed card shown when zero groups exist
class EmptyGroupCard extends StatelessWidget {
  const EmptyGroupCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      targetScale: 0.96,
      child: Container(
        width: 126,
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
            width: PremiumDesignTokens.cardBorderWidth,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 22,
              color: PremiumDesignTokens.green600,
            ),
            SizedBox(height: 4),
            Text(
              '+ New Group',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: PremiumDesignTokens.green600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
