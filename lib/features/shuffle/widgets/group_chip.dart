import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// Tag-like group indicator chip (e.g. "Cricket 6").
/// Features a soft cream/sage background, subtle hairline border,
/// and calm moss green iconography.
class GroupChip extends StatelessWidget {
  const GroupChip({
    super.key,
    required this.name,
    this.icon = Icons.sports_cricket_rounded,
  });

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF222F26)
            : PremiumDesignTokens.sageLight,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.radiusPill),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334638)
              : PremiumDesignTokens.sageBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isDark
                ? const Color(0xFFABC4B3)
                : PremiumDesignTokens.sageText,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFABC4B3)
                  : PremiumDesignTokens.sageText,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
