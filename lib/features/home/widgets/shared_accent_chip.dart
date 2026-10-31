import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Reusable pill-shaped accent chip matching Level 2 Inner Elements:
/// - Solid #FFFFFF background
/// - 1px border rgba(27,67,50,0.10)
/// - Small shadow [0 1px 4px rgba(27,67,50,0.05)]
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
    final bg = backgroundColor ?? Colors.white;
    final fg = textColor ?? PremiumDesignTokens.textPrimary;
    final ic = iconColor ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? PremiumDesignTokens.innerBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B4332), // rgba(27,67,50,0.05)
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
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
