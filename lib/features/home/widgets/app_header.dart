import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Top header row matching Section 5.2 of the Master Prompt:
/// - Left: 48x48 app logo tile, radius 14, gradPrimary, white Shuffle icon, inner highlight, shadow
/// - Title: "Shuffle Master" (Shuffle in --text-strong, Master in --green-600)
/// - Tagline: "Randomize anything. Decide instantly."
/// - Right: Circular 44x44 profile button with peach/cream gradient, glass border, soft shadow
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumDesignTokens.sp4,
        vertical: PremiumDesignTokens.sp3,
      ),
      child: Row(
        children: [
          // 48 x 48 App Logo Tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: PremiumDesignTokens.gradPrimary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: PremiumDesignTokens.shadowButton,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.shuffle_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Two-Tone Brand Title & Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Shuffle ',
                    style: TextStyle(
                      fontFamily: theme.textTheme.titleLarge?.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark
                          ? const Color(0xFFEAF1EB)
                          : PremiumDesignTokens.textStrong,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Master',
                        style: TextStyle(
                          color: PremiumDesignTokens.green600,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Randomize anything. Decide instantly.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFA6B7AA)
                        : PremiumDesignTokens.textBody,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Circular 44 x 44 Profile Button
          PressableScale(
            onTap: () => context.go('/settings'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF263327), Color(0xFF1F2B21)]
                      : const [
                          PremiumDesignTokens.peach50,
                          Color(0xFFF7ECE0),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF384A3B)
                      : PremiumDesignTokens.borderGlass,
                ),
                boxShadow: PremiumDesignTokens.shadowSm,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 22,
                color: isDark
                    ? const Color(0xFFBACDBF)
                    : PremiumDesignTokens.textStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
