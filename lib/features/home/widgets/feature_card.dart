import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Feature card matching Section 5.4 of the Master Prompt:
/// - Radius 24, padding 14, min-height ~170, 1px borderSoft, shadowMd / shadowPeach
/// - A) Name Shuffle: gradMintCard, icon 40x40 gradPrimary, arrow button, title, body,
///      "Fair & Instant" chip, 3 mini tilted name chips (Aarav, Neha, Karan) + orange sparks
/// - B) Coin Toss: gradPeachCard, icon 40x40 gradOrange, arrow button, title, body,
///      "3D Animation" chip, 3D gold coin with crown emblem + smaller satellite coins + 3D tilt
class FeatureCard extends StatefulWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.badgeIcon,
    required this.backgroundColor,
    this.backgroundGradient,
    required this.iconBoxColor,
    this.iconBoxGradient,
    this.arrowButtonBg,
    this.floatingPills,
    this.hasCoinGraphic = false,
    this.isPeachCard = false,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final IconData badgeIcon;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Color iconBoxColor;
  final Gradient? iconBoxGradient;
  final Color? arrowButtonBg;
  final List<String>? floatingPills;
  final bool hasCoinGraphic;
  final bool isPeachCard;
  final VoidCallback onTap;

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tiltController;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final grad = widget.backgroundGradient ??
        (widget.isPeachCard
            ? PremiumDesignTokens.gradPeachCard
            : PremiumDesignTokens.gradMintCard);

    final shadows = widget.isPeachCard
        ? PremiumDesignTokens.shadowPeach
        : PremiumDesignTokens.shadowMd;

    final arrowBg = widget.arrowButtonBg ??
        (widget.isPeachCard
            ? PremiumDesignTokens.peach100
            : PremiumDesignTokens.green100);

    return PressableScale(
      onTap: widget.onTap,
      child: Container(
        height: 205,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222F26) : null,
          gradient: isDark ? null : grad,
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
          border: Border.all(
            color: isDark
                ? const Color(0xFF354437)
                : PremiumDesignTokens.borderSoft,
          ),
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: 40x40 Icon Tile + 28px Arrow Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.iconBoxGradient == null
                              ? widget.iconBoxColor
                              : null,
                          gradient: widget.iconBoxGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            widget.icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // 28px Circular Arrow Button
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E3D31) : arrowBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PremiumDesignTokens.borderSoft,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFFD2E3D6)
                              : PremiumDesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title (18/22 700 --text-strong)
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFEAF1EB)
                          : PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Body (12.5/18 400 --text-body)
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFFA2B4A6)
                          : PremiumDesignTokens.textBody,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Bottom Pill Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2E3D30)
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(
                        PremiumDesignTokens.rPill,
                      ),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3B4F3E)
                            : PremiumDesignTokens.borderSoft,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.badgeIcon,
                          size: 12,
                          color: widget.isPeachCard
                              ? PremiumDesignTokens.orange500
                              : PremiumDesignTokens.green600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.badgeText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: widget.isPeachCard
                                ? PremiumDesignTokens.orange500
                                : PremiumDesignTokens.green600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Visual Decorative Element on the bottom right:
              // Floating name chips for Shuffle, 3D Gold Coins for Coin Toss
              if (widget.floatingPills != null)
                Positioned(
                  right: -2,
                  bottom: 8,
                  child: _buildShuffleDecor(isDark),
                )
              else if (widget.hasCoinGraphic)
                Positioned(
                  right: -8,
                  bottom: -6,
                  child: reduceMotion
                      ? _buildCoinGraphicStatic()
                      : AnimatedBuilder(
                          animation: _tiltController,
                          builder: (context, _) => _buildCoinGraphicAnimated(),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShuffleDecor(bool isDark) {
    return SizedBox(
      width: 78,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // Orange spark
          Positioned(
            top: 2,
            right: 28,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 6,
                height: 2.5,
                decoration: BoxDecoration(
                  color: PremiumDesignTokens.orange500,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),

          // Mini Tilted Chips: Aarav (white), Neha (sage), Karan (cream)
          Positioned(
            top: 6,
            right: 8,
            child: Transform.rotate(
              angle: -0.15,
              child: _buildMiniChip('Aarav', Colors.white, isDark),
            ),
          ),
          Positioned(
            top: 22,
            right: 0,
            child: Transform.rotate(
              angle: 0.12,
              child: _buildMiniChip(
                'Neha',
                PremiumDesignTokens.green100,
                isDark,
              ),
            ),
          ),
          Positioned(
            top: 36,
            right: 14,
            child: Transform.rotate(
              angle: -0.06,
              child: _buildMiniChip(
                'Karan',
                PremiumDesignTokens.peach50,
                isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMiniChip(String label, Color bg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF28362B) : bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: isDark
              ? const Color(0xFFD5E3D8)
              : PremiumDesignTokens.textStrong,
        ),
      ),
    );
  }

  Widget _buildCoinGraphicStatic() {
    return _buildCoins(0.0);
  }

  Widget _buildCoinGraphicAnimated() {
    final tilt = math.sin(_tiltController.value * math.pi * 2) * 0.15;
    return _buildCoins(tilt);
  }

  Widget _buildCoins(double tilt) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Satellite mini coin behind
          Positioned(
            right: 32,
            top: 6,
            child: Transform.rotate(
              angle: -0.3 + tilt,
              child: Container(
                width: 18,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCE29A), Color(0xFFD99A22)],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25D99A22),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main 3D Gold Coin with Crown Emblem
          Positioned(
            right: 0,
            bottom: 4,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(tilt),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.25, -0.25),
                    radius: 0.85,
                    colors: [
                      Color(0xFFFCE29A),
                      Color(0xFFE9B44C),
                      Color(0xFFC98A14),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFF3C2),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3DF28C28),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded, // crown glyph
                    color: Color(0xFF8B5A0C),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
