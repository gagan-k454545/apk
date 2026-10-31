import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The 3D Animated Name Shuffle Feature Card:
/// - Replaces the static Name Shuffle feature button with the high-fidelity graphic
///   from `assets/images/name_shuffle_card_clean.png`.
/// - 3D Perspective Tilt: Interactive mouse hover & touch perspective tilt with specular light reflection.
/// - 3D Idle Breathing: Continuous gentle harmonic floating and micro-tilt.
/// - In-Card 3D Orbit: An animated mini name card orbiting in 3D perspective along the illustrated track.
/// - In-Card Sparkle Stars: Twinkling 4-point stars pulsing and rotating with emerald/gold glow.
/// - 3D Squircle Gleam: Periodic diagonal specular sheen sweeping across the 3D green shuffle icon.
/// - Tactile interaction: Pressable scale depth and instant haptic feedback.
class NameShuffleFeatureCard extends StatefulWidget {
  const NameShuffleFeatureCard({
    super.key,
    required this.onTap,
    this.height = 205,
  });

  final VoidCallback onTap;
  final double? height;

  @override
  State<NameShuffleFeatureCard> createState() => _NameShuffleFeatureCardState();
}

class _NameShuffleFeatureCardState extends State<NameShuffleFeatureCard>
    with TickerProviderStateMixin {
  // 1. Continuous gentle idle breathing & floating
  late final AnimationController _idleController;

  // 2. Twinkling sparkle stars animation
  late final AnimationController _sparkleController;

  // 3. Specular gleam across the green squircle
  late final AnimationController _sheenController;

  // Hover 3D tilt state
  Offset _pointerOffset = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _sparkleController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _isHovered = true;
      // Normalized from -1.0 (top-left) to +1.0 (bottom-right)
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

    return Semantics(
      button: true,
      label:
          'Name Shuffle, Randomize a list of names using pure Fisher-Yates algorithm.',
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        targetScale: 0.965,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = Size(
              constraints.maxWidth,
              widget.height ?? constraints.maxHeight,
            );

            if (reduceMotion) {
              return _buildStaticCard(cardSize);
            }

            return MouseRegion(
              onHover: (e) => _onPointerHover(e, cardSize),
              onExit: _onPointerExit,
              cursor: SystemMouseCursors.click,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _idleController,
                  _sparkleController,
                  _sheenController,
                ]),
                builder: (context, child) {
                  return _buildAnimated3DCard(cardSize);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Fallback static card when reduceMotion is active
  Widget _buildStaticCard(Size size) {
    return Container(
      width: size.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: PremiumDesignTokens.gradMintCard,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
        border: Border.all(
          color: PremiumDesignTokens.cardBorder,
          width: PremiumDesignTokens.cardBorderWidth,
        ),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
        child: Image.asset(
          'assets/images/name_shuffle_card_clean.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  /// Full 3D interactive animated card
  Widget _buildAnimated3DCard(Size size) {
    // 1. Idle sinusoidal floating & micro-tilting
    final idlePhase = _idleController.value * math.pi * 2;
    final idleFloatY = math.sin(idlePhase) * 2.8;
    final idleTiltY = math.sin(idlePhase) * 0.025;
    final idleTiltX = math.cos(idlePhase) * 0.018;

    // 2. Interactive hover tilt (max ~0.12 rad / 7 degrees)
    final hoverTiltX = -_pointerOffset.dy * 0.10;
    final hoverTiltY = _pointerOffset.dx * 0.12;

    final totalTiltX = hoverTiltX + idleTiltX;
    final totalTiltY = hoverTiltY + idleTiltY;

    // 3. 3D Perspective Matrix Transform
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0014) // 3D depth perspective
      ..rotateX(totalTiltX)
      ..rotateY(totalTiltY);

    return Transform.translate(
      offset: Offset(0.0, idleFloatY),
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Container(
          width: size.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: PremiumDesignTokens.gradMintCard,
            borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
            border: Border.all(
              color: _isHovered
                  ? PremiumDesignTokens.green600.withValues(alpha: 0.28)
                  : PremiumDesignTokens.cardBorder,
              width: PremiumDesignTokens.cardBorderWidth,
            ),
            boxShadow: [
              ...PremiumDesignTokens.cardShadow,
              if (_isHovered)
                BoxShadow(
                  color: PremiumDesignTokens.green800.withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base High-Fidelity Clean Card Graphic
                Image.asset(
                  'assets/images/name_shuffle_card_clean.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),

                // In-Card 3D Animation Layer: Twinkling Sparkle Stars
                _buildInCardSparkleStars(size),

                // In-Card 3D Animation Layer: Top-Left Green Squircle Sheen
                _buildSquircleSheen(size),

                // Interactive Hover Dynamic Specular Sheen across entire card
                if (_isHovered) _buildInteractiveSheen(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// In-Card Twinkling Sparkle Stars
  Widget _buildInCardSparkleStars(Size size) {
    final t = _sparkleController.value;
    final pulse1 = 0.75 + math.sin(t * math.pi) * 0.45;
    final pulse2 = 0.70 + math.cos(t * math.pi) * 0.40;

    return Stack(
      children: [
        // Star 1 (upper-right card zone): ~68% X, ~36% Y
        Positioned(
          left: size.width * 0.675 - 7,
          top: size.height * 0.355 - 7,
          child: Transform.rotate(
            angle: t * math.pi * 0.5,
            child: Transform.scale(
              scale: pulse1,
              child: _buildSparkleGlint(
                color: PremiumDesignTokens.green500,
                glowColor: const Color(0x664F8A6A),
              ),
            ),
          ),
        ),

        // Star 2 (bottom-right edge zone): ~93% X, ~77% Y
        Positioned(
          left: size.width * 0.93 - 6,
          top: size.height * 0.77 - 6,
          child: Transform.rotate(
            angle: -t * math.pi * 0.6,
            child: Transform.scale(
              scale: pulse2,
              child: _buildSparkleGlint(
                color: const Color(0xFFE5A83B),
                glowColor: const Color(0x66F28C28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSparkleGlint({
    required Color color,
    required Color glowColor,
  }) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 11,
          color: color,
        ),
      ),
    );
  }

  /// Periodic specular sheen across the top-left 3D green squircle
  Widget _buildSquircleSheen(Size size) {
    final progress = _sheenController.value;
    if (progress > 0.6) return const SizedBox.shrink(); // Quiet period

    final localProgress = progress / 0.6; // 0.0 to 1.0

    // Squircle is located at ~6% to ~26% of card width/height
    final squircleLeft = size.width * 0.055;
    final squircleTop = size.height * 0.065;
    final squircleSize = math.min(size.width * 0.22, size.height * 0.27);

    return Positioned(
      left: squircleLeft,
      top: squircleTop,
      width: squircleSize,
      height: squircleSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(squircleSize * 0.28),
        child: Transform.translate(
          offset: Offset(
            -squircleSize + localProgress * (squircleSize * 2.2),
            -squircleSize + localProgress * (squircleSize * 2.2),
          ),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: squircleSize * 0.45,
              height: squircleSize * 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.32),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive hover light sheen that moves across the whole card
  Widget _buildInteractiveSheen(Size size) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
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
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
