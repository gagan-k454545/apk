import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'pressable_scale.dart';

/// The premium scaffold layout designed for high-end mobile experiences.
/// Includes the frosted circular action buttons, group chip pill,
/// and safe scroll area with bottom shield.
class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.body,
    this.groupName,
    this.groupIcon = Icons.groups_rounded,
    this.onBack,
    this.onShare,
    this.onCopy,
    this.bottomNavigationBar,
  });

  final Widget body;
  final String? groupName;
  final IconData groupIcon;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  // Back Button (Translucent Circular Pill)
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

                  // Group Label Chip (e.g. "Cricket 6")
                  if (groupName != null && groupName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222F26)
                            : AppColors.sageLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334638)
                              : AppColors.sageBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            groupIcon,
                            size: 15,
                            color: isDark
                                ? const Color(0xFFABC4B3)
                                : AppColors.sageOnContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            groupName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFABC4B3)
                                  : AppColors.sageOnContainer,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

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
            ),

            // Scrollable Content
            Expanded(
              child: body,
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? SafeArea(
              top: false,
              child: bottomNavigationBar!,
            )
          : null,
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
                : AppColors.creamCard.withValues(alpha: 0.9),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334437)
                  : AppColors.hairline,
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
