import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'pressable_scale.dart';

/// The featured #1 Winner card in the randomized leaderboard.
/// Features a warm champagne-ivory gradient, delicate gold border glow with
/// breathing ambient depth, medal icon, avatar with initials, and a tactile "WINNER" pill badge.
class WinnerMemberCard extends StatefulWidget {
  const WinnerMemberCard({
    super.key,
    required this.name,
    this.rank = 1,
    this.onTap,
  });

  final String name;
  final int rank;
  final VoidCallback? onTap;

  @override
  State<WinnerMemberCard> createState() => _WinnerMemberCardState();
}

class _WinnerMemberCardState extends State<WinnerMemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _getInitials(String rawName) {
    final parts = rawName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return PressableScale(
      onTap: widget.onTap,
      child: Semantics(
        label: 'Winner, Rank ${widget.rank}: ${widget.name}',
        button: true,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowVal = reduceMotion ? 0.5 : _glowController.value;
            final glowOpacity = 0.12 + (glowVal * 0.14);
            final glowSpread = 0.5 + (glowVal * 2.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                          Color(0xFF263327),
                          Color(0xFF1E2820),
                        ]
                      : const [
                          Color(0xFFFFFDF8),
                          Color(0xFFFBF4E7),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? Color.lerp(
                          const Color(0xFF6E5624),
                          const Color(0xFF9E7E36),
                          glowVal,
                        )!
                      : Color.lerp(
                          AppColors.goldBorder,
                          const Color(0xFFECC270),
                          glowVal,
                        )!,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? const Color(0xFFE2B75E)
                            : AppColors.warmGold)
                        .withValues(alpha: glowOpacity),
                    blurRadius: 18 + (glowVal * 6),
                    spreadRadius: glowSpread,
                    offset: const Offset(0, 5),
                  ),
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: child,
            );
          },
          child: Row(
            children: [
              // Medal / Rank icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3E3113)
                      : const Color(0xFFF8ECD0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF6E5624)
                        : const Color(0xFFE5C885),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 20,
                    color: AppColors.warmGold,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Avatar with Initials
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF7E6C2),
                      Color(0xFFE9CCA0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5C588),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(widget.name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name and Leaderboard Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rank #1 • Top Pick',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFFD6BA80)
                            : const Color(0xFF8B641C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // WINNER badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE3AB3E),
                      Color(0xFFC78E24),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28C78E24),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'WINNER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
