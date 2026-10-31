import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Reusable pill-shaped accent chip matching the reference design (Strictly Light Theme):
/// - "🚀 MAKE DECISIONS EASIER"
/// - "🛡️ Fair & Instant"
/// - "📦 3D Animation"
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
    final bg = backgroundColor ?? Colors.white.withValues(alpha: 0.85);
    final fg = textColor ?? PremiumDesignTokens.textPrimary;
    final ic = iconColor ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : Border.all(
                color: PremiumDesignTokens.borderSoft,
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
