import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Reusable Group Card matching Section 5.7 of the Master Prompt (Strictly Light Theme):
/// - 120px wide, height ~78, radius 18, bg --surface-soft, 1px borderSoft, shadowSm
/// - Top-left: 32x32 icon tile (radius 10)
/// - Top-right: 32px hit area MoreVertical (kebab) button
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
        width: 120,
        height: 78,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PremiumDesignTokens.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.borderSoft,
          ),
          boxShadow: PremiumDesignTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: 32x32 Icon Tile + Kebab Menu (32px touch target)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconTileBg,
                    borderRadius: BorderRadius.circular(10),
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
                    width: 32,
                    height: 32,
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
                    color: PremiumDesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$memberCount names',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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
        width: 120,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.green600.withValues(alpha: 0.4),
            width: 1.2,
          ),
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
