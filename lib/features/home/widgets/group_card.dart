import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Reusable Group Card matching Section 5.7 of the Master Prompt (Strictly Light Theme):
/// - 124px wide, height 94px, radius 18, bg --surface-soft, 1px borderSoft, shadowSm
/// - Top-left: 30x30 icon tile (radius 10)
/// - Top-right: MoreVertical (kebab) button
/// - Spacer for adaptive vertical breathing room (prevents font scaling overflow)
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
        width: 124,
        height: 94,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    color: PremiumDesignTokens.textStrong,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
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
        width: 124,
        height: 94,
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
