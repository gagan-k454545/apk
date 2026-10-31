import 'package:flutter/material.dart';

/// Reusable squircle icon tile matching the reference design.
/// Used for:
/// - Header brand shuffle mark
/// - Feature cards icon box (green shuffle / orange coin)
/// - Quick action tile icon container
class SharedIconTile extends StatelessWidget {
  const SharedIconTile({
    super.key,
    required this.icon,
    this.size = 40.0,
    this.iconSize = 22.0,
    this.backgroundColor,
    this.gradient,
    this.iconColor = Colors.white,
    this.borderRadius = 13.0,
    this.border,
    this.boxShadow,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color iconColor;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
