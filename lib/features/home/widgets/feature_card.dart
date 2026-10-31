import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Feature card matching Section 5.4 & Level 1 Surface Hierarchy:
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, `<pastel tint>` 100%)
/// - Border: 1px solid rgba(27,67,50,0.12)
/// - Shadow: Two-layer shadow [0 1px 2px rgba(27,67,50,0.06), 0 10px 28px rgba(27,67,50,0.12)]
/// - Arrow circle buttons: solid tinted fill (mint #D5E6D0 / peach #F9D3BA) with visible border
/// - Chips: solid #FFFFFF with 1px border rgba(27,67,50,0.10) and small shadow
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
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final grad = widget.backgroundGradient ??
        (widget.isPeachCard
            ? PremiumDesignTokens.gradPeachCard
            : PremiumDesignTokens.gradMintCard);

    // Solid tinted fill for arrow circle button (Section 3)
    final arrowBg = widget.arrowButtonBg ??
        (widget.isPeachCard
            ? const Color(0xFFF9D3BA) // peach #F9D3BA
            : const Color(0xFFD5E6D0)); // mint #D5E6D0

    return PressableScale(
      onTap: widget.onTap,
      child: Container(
        height: 205,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: 40x40 Icon Tile + Solid Tinted 28px Arrow Button
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

                      // Solid Tinted Arrow Button (not translucent!)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: arrowBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PremiumDesignTokens.innerBorder,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: PremiumDesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title (18/22 700 --text-strong)
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Body (12.5/18 400 --text-body)
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: PremiumDesignTokens.textBody,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Level 2 Pill Chip: Solid #FFFFFF + 1px border rgba(27,67,50,0.10) + small shadow
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        PremiumDesignTokens.rPill,
                      ),
                      border: Border.all(
                        color: PremiumDesignTokens.innerBorder,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D1B4332),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
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

              // Visual Decorative Cropped Assets:
              if (widget.floatingPills != null)
                Positioned(
                  right: -4,
                  bottom: 4,
                  width: 90,
                  height: 74,
                  child: Image.asset(
                    'assets/ui/chips-cluster.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                )
              else if (widget.hasCoinGraphic)
                Positioned(
                  right: -8,
                  bottom: -4,
                  width: 100,
                  height: 85,
                  child: reduceMotion
                      ? Image.asset(
                          'assets/ui/coin-3d.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        )
                      : AnimatedBuilder(
                          animation: _tiltController,
                          builder: (context, child) {
                            final tilt = math.sin(
                                    _tiltController.value * math.pi * 2) *
                                0.12;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateY(tilt),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/ui/coin-3d.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
