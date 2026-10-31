import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Reusable pill-shaped accent chip matching the reference design.
/// Used for:
/// - "🚀 MAKE DECISIONS EASIER"
/// - "🛡️ Fair & Instant"
/// - "📦 3D Animation"
/// - "7 members in Cricket 6"
class SharedAccentChip extends StatelessWidget {
  const SharedAccentChip({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.fontSize = 10.0,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 0.4,
    this.borderRadius = 16.0,
  });

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = backgroundColor ??
        (isDark
            ? const Color(0xFF263228)
            : Colors.white.withValues(alpha: 0.85));
    final fg = textColor ??
        (isDark ? const Color(0xFFBACDBF) : PremiumDesignTokens.textPrimary);
    final ic = iconColor ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : Border.all(
                color: isDark
                    ? const Color(0xFF354437)
                    : const Color(0x1F000000),
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null) ...[
            iconWidget!,
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: ic),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
