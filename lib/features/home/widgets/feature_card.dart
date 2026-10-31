import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';
import 'shared_accent_chip.dart';
import 'shared_icon_tile.dart';

/// Feature card matching the reference screenshot.
/// Used for:
/// - "Name Shuffle" (Sage green with floating name pills + avatars + "Fair & Instant" badge)
/// - "Coin Toss" (Warm peach with 3D gold coin + crown + "3D Animation" badge)
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.badgeIcon,
    required this.backgroundColor,
    required this.iconBoxColor,
    this.floatingPills,
    this.hasCoinGraphic = false,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final IconData badgeIcon;
  final Color backgroundColor;
  final Color iconBoxColor;
  final List<String>? floatingPills;
  final bool hasCoinGraphic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 228,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? const Color(0xFF354437)
                : PremiumDesignTokens.hairline.withValues(alpha: 0.8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon Squircle + Circular Arrow Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SharedIconTile(
                  icon: icon,
                  size: 36,
                  iconSize: 20,
                  backgroundColor: iconBoxColor,
                  borderRadius: 10,
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2E3830)
                        : Colors.white.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: isDark
                        ? const Color(0xFFBACDBF)
                        : PremiumDesignTokens.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),

            // Description
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                height: 1.3,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Visual Graphic Area (Pills + Avatars OR 3D Coin with Floating Coins)
            if (floatingPills != null)
              _buildNameShuffleGraphic(isDark)
            else if (hasCoinGraphic)
              _buildCoinTossGraphic(),

            const Spacer(),

            // Bottom Badge Pill
            SharedAccentChip(
              label: badgeText,
              icon: badgeIcon,
              iconColor: iconBoxColor,
              textColor: iconBoxColor,
              backgroundColor: isDark
                  ? const Color(0xFF243026)
                  : Colors.white.withValues(alpha: 0.75),
              borderColor: isDark
                  ? const Color(0xFF334336)
                  : Colors.white.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameShuffleGraphic(bool isDark) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Floating small name pills
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallPill('Aarav', isDark),
                  const SizedBox(width: 4),
                  _buildSmallPill('Neha', isDark),
                ],
              ),
              const SizedBox(height: 4),
              _buildSmallPill('Karan', isDark),
            ],
          ),

          // Overlapping avatars on the right
          Positioned(
            right: 0,
            bottom: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniAvatar(const Color(0xFF8BB59A), 22),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: _buildMiniAvatar(const Color(0xFFA5C9B3), 24),
                ),
              ],
            ),
          ),

          // Sparkle accent
          Positioned(
            right: 28,
            top: 2,
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: const BoxDecoration(
                color: Color(0xFFD67E2D),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSmallPill(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF28362B)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: isDark
              ? const Color(0xFFD5E3D8)
              : PremiumDesignTokens.textPrimary,
        ),
      ),
    );
  }

  static Widget _buildMiniAvatar(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCoinTossGraphic() {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Floating background mini coins
          Positioned(
            right: 38,
            top: 4,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 14,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF88), Color(0xFFE89A38)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 2,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 16,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF88), Color(0xFFE89A38)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          // Main 3D Gold Coin with embossed crown
          Positioned(
            right: 8,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.2, -0.3),
                  radius: 0.85,
                  colors: [
                    Color(0xFFFFE082),
                    Color(0xFFF9A825),
                    Color(0xFFE65100),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFFF3B0),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35E65100),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFFF9E6),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
