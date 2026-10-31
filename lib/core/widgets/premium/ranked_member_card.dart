import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'pressable_scale.dart';

/// Clean, tactile, elegant card for members ranked 2 and below.
/// Shows rank indicator, avatar circle, member name, and subtle trailing drag/options icon.
class RankedMemberCard extends StatelessWidget {
  const RankedMemberCard({
    super.key,
    required this.name,
    required this.rank,
    this.onTap,
    this.animationDelayMs = 0,
  });

  final String name;
  final int rank;
  final VoidCallback? onTap;
  final int animationDelayMs;

  String _getInitials(String rawName) {
    final parts = rawName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _getRankBadgeColor(bool isDark) {
    if (rank == 2) {
      return isDark ? const Color(0xFF333B3E) : const Color(0xFFE8EEF0);
    }
    if (rank == 3) {
      return isDark ? const Color(0xFF3C3127) : const Color(0xFFF6EDE3);
    }
    return isDark ? const Color(0xFF222B24) : AppColors.sageLight;
  }

  Color _getRankTextColor(bool isDark) {
    if (rank == 2) {
      return isDark ? const Color(0xFF90A4AE) : const Color(0xFF455A64);
    }
    if (rank == 3) {
      return isDark ? const Color(0xFFBCAAA4) : const Color(0xFF795548);
    }
    return isDark ? const Color(0xFFABC4B3) : AppColors.sageOnContainer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PressableScale(
      onTap: onTap,
      child: Semantics(
        label: 'Rank $rank: $name',
        button: true,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4.5),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.creamCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C3930)
                  : AppColors.hairline.withValues(alpha: 0.8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x061E3A2B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Rank Pill
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankBadgeColor(isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getRankTextColor(isDark),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Avatar with Initials
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF28362B)
                      : AppColors.warmBeige,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3B4D3F)
                        : const Color(0xFFE8DFCE),

                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFB4C8B9)
                          : AppColors.textHeadline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Trailing Options or Reorder Icon
              Icon(
                Icons.drag_indicator_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
