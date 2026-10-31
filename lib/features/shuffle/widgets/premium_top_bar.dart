import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';
import 'group_chip.dart';

/// Top bar with back navigation, group tag chip, and share/copy actions.
class PremiumTopBar extends StatelessWidget {
  const PremiumTopBar({
    super.key,
    required this.groupName,
    this.onBack,
    this.onCopy,
    this.onShare,
    this.onSortAlphabetical,
  });

  final String groupName;
  final VoidCallback? onBack;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onSortAlphabetical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          // Back Button
          if (onBack != null)
            _buildCircularButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: onBack!,
              isDark: isDark,
              theme: theme,
            )
          else
            const SizedBox(width: 42),

          const SizedBox(width: 12),

          // Group Tag Chip (e.g. "Cricket 6")
          GroupChip(name: groupName),

          const Spacer(),

          // Sort Alphabetically Action Button
          if (onSortAlphabetical != null) ...[
            _buildCircularButton(
              icon: Icons.sort_by_alpha_rounded,
              tooltip: 'Sort Names A-Z',
              onTap: onSortAlphabetical!,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(width: 10),
          ],

          // Copy Action Button
          if (onCopy != null)
            _buildCircularButton(
              icon: Icons.copy_rounded,
              tooltip: 'Copy Order',
              onTap: onCopy!,
              isDark: isDark,
              theme: theme,
            ),

          if (onCopy != null && onShare != null)
            const SizedBox(width: 10),

          // Share Action Button
          if (onShare != null)
            _buildCircularButton(
              icon: Icons.share_rounded,
              tooltip: 'Share',
              onTap: onShare!,
              isDark: isDark,
              theme: theme,
            ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? const Color(0xFF202A22)
                : PremiumDesignTokens.surface.withValues(alpha: 0.9),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334437)
                  : PremiumDesignTokens.hairline,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
