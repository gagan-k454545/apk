import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';
import 'shared_icon_tile.dart';

/// Top header bar for the Shuffle Master home screen.
/// Features:
/// - Dark green squircle brand shuffle icon
/// - "Shuffle Master" title with two-tone styling
/// - "Randomize anything. Decide instantly." subtitle
/// - User profile circular button
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          // Brand Icon Squircle
          const SharedIconTile(
            icon: Icons.shuffle_rounded,
            size: 44,
            iconSize: 24,
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3A2B),
                Color(0xFF2C553C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: 14,
            boxShadow: [
              BoxShadow(
                color: Color(0x181E3A2B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Brand Title & Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Shuffle ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Master',
                        style: TextStyle(
                          color: PremiumDesignTokens.mossPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Randomize anything. Decide instantly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // User Profile Button
          PressableScale(
            onTap: () => context.go('/settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF232D25)
                    : PremiumDesignTokens.warmBeige,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF354437)
                      : const Color(0xFFEADBCA),
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: isDark
                    ? const Color(0xFFBACDBF)
                    : PremiumDesignTokens.mossDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
