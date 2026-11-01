import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// Cinematic 3D Quick Action Tile matching Section 5.5 & Level 1 Surface Hierarchy:
/// - Surface: linear-gradient(160deg, #FFFFFF 0%, #FBF7F0 100%)
/// - 3D Perspective Tilt: Interactive mouse hover & touch perspective tilt with specular shine.
/// - Dynamic elevation lift & branded color glow shadow on hover.
/// - Saturated gradient icon tile with diagonal gleam.
/// - 12px label in --text-strong with tactile press scale.
class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.backgroundGradient,
    required this.iconTileGradient,
    required this.onTap,
    this.glowColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Gradient iconTileGradient;
  final VoidCallback onTap;
  final Color? glowColor;

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gleamController;

  Offset _pointerOffset = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _gleamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _gleamController.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _isHovered = true;
      _pointerOffset = Offset(
        (event.localPosition.dx / size.width) * 2.0 - 1.0,
        (event.localPosition.dy / size.height) * 2.0 - 1.0,
      );
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
      _pointerOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final baseGlow = widget.glowColor ??
        (widget.iconTileGradient is LinearGradient
            ? (widget.iconTileGradient as LinearGradient).colors.first
            : PremiumDesignTokens.green800);

    return MouseRegion(
      onHover: (e) => _onPointerHover(e, const Size(80, 74)),
      onExit: _onPointerExit,
      cursor: SystemMouseCursors.click,
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        targetScale: 0.94,
        child: AnimatedBuilder(
          animation: _gleamController,
          builder: (context, child) {
            // 3D Perspective Tilt on Hover
            final tiltX = reduceMotion ? 0.0 : -_pointerOffset.dy * 0.12;
            final tiltY = reduceMotion ? 0.0 : _pointerOffset.dx * 0.14;
            final liftY = _isHovered && !reduceMotion ? -3.5 : 0.0;

            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateX(tiltX)
              ..rotateY(tiltY);

            return Transform.translate(
              offset: Offset(0.0, liftY),
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: Container(
                  height: 74,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: widget.backgroundGradient ??
                        PremiumDesignTokens.gradNeutralCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? baseGlow.withValues(alpha: 0.35)
                          : PremiumDesignTokens.cardBorder,
                      width: PremiumDesignTokens.cardBorderWidth,
                    ),
                    boxShadow: [
                      ...PremiumDesignTokens.cardShadow,
                      if (_isHovered)
                        BoxShadow(
                          color: baseGlow.withValues(alpha: 0.18),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 34 x 34 Saturated Gradient Icon Tile with 3D Bevel & Gleam
                          _buildIconTile(baseGlow, reduceMotion),
                          const SizedBox(height: 5),

                          // 11px Label in --text-strong with auto-fit protection
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: PremiumDesignTokens.textStrong,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                      // Interactive dynamic specular sheen across tile
                      if (_isHovered && !reduceMotion)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -_pointerOffset.dx - 0.4,
                                    -_pointerOffset.dy - 0.4,
                                  ),
                                  end: Alignment(
                                    -_pointerOffset.dx + 0.4,
                                    -_pointerOffset.dy + 0.4,
                                  ),
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.16),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconTile(Color baseGlow, bool reduceMotion) {
    final gleamProgress = _gleamController.value;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: widget.iconTileGradient,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: baseGlow.withValues(alpha: 0.28),
            blurRadius: 7,
            offset: const Offset(0, 2.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icon
            Icon(
              widget.icon,
              size: 18,
              color: Colors.white,
            ),

            // Diagonal Light Gleam across squircle
            if (!reduceMotion && gleamProgress <= 0.6)
              Transform.translate(
                offset: Offset(
                  -34.0 + (gleamProgress / 0.6) * 68.0,
                  -34.0 + (gleamProgress / 0.6) * 68.0,
                ),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 14,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
