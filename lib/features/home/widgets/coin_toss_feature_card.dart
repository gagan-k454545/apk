import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The 3D Animated Coin Toss Feature Card:
/// - Replaces the static Coin Toss feature card with the same 3D floating and moving
///   animations applied to the Name Shuffle button.
/// - 3D Perspective Tilt: Interactive mouse hover & touch perspective tilt with specular light reflection.
/// - 3D Idle Breathing: Continuous gentle harmonic floating and micro-tilt.
/// - In-Card 3D Coins: Crisp, beautifully layered 3D golden coins floating with perspective tilt and metallic shine.
/// - In-Card Sparkle Stars: Twinkling 4-point golden/amber stars pulsing and rotating with light halos.
/// - 3D Orange Squircle Gleam: Periodic diagonal specular sheen sweeping across the top-left coin icon.
/// - Tactile interaction: Pressable scale depth and instant haptic feedback.
/// - Strict dimensional parity with NameShuffleFeatureCard for flawless row alignment.
class CoinTossFeatureCard extends StatefulWidget {
  const CoinTossFeatureCard({
    super.key,
    required this.onTap,
    this.height = 205,
  });

  final VoidCallback onTap;
  final double? height;

  @override
  State<CoinTossFeatureCard> createState() => _CoinTossFeatureCardState();
}

class _CoinTossFeatureCardState extends State<CoinTossFeatureCard>
    with TickerProviderStateMixin {
  // 1. Continuous gentle idle breathing & floating
  late final AnimationController _idleController;

  // 2. Twinkling sparkle stars animation
  late final AnimationController _sparkleController;

  // 3. Specular gleam across the orange squircle
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
      container: true,
      excludeSemantics: true,
      button: true,
      label:
          'Coin Toss, Make a quick 50/50 heads-or-tails decision with 3D animation.',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: PremiumDesignTokens.gradPeachCard,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
        border: Border.all(
          color: PremiumDesignTokens.cardBorder,
          width: PremiumDesignTokens.cardBorderWidth,
        ),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
        child: Stack(
          children: [
            _buildCardContent(),
            _buildStaticCoins(),
          ],
        ),
      ),
    );
  }

  /// Full 3D interactive animated card
  Widget _buildAnimated3DCard(Size size) {
    // 1. Idle sinusoidal floating & micro-tilting (matches NameShuffleFeatureCard)
    final idlePhase = _idleController.value * math.pi * 2;
    final idleFloatY = math.sin(idlePhase) * 2.8;
    final idleTiltY = math.sin(idlePhase) * 0.025;
    final idleTiltX = math.cos(idlePhase) * 0.018;

    // 2. Interactive hover tilt
    final hoverTiltX = -_pointerOffset.dy * 0.10;
    final hoverTiltY = _pointerOffset.dx * 0.12;

    final totalTiltX = hoverTiltX + idleTiltX;
    final totalTiltY = hoverTiltY + idleTiltY;

    // 3. 3D Perspective Matrix Transform
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0014)
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: PremiumDesignTokens.gradPeachCard,
            borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
            border: Border.all(
              color: _isHovered
                  ? PremiumDesignTokens.orange500.withValues(alpha: 0.28)
                  : PremiumDesignTokens.cardBorder,
              width: PremiumDesignTokens.cardBorderWidth,
            ),
            boxShadow: [
              ...PremiumDesignTokens.cardShadow,
              if (_isHovered)
                BoxShadow(
                  color: PremiumDesignTokens.orange500.withValues(alpha: 0.14),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PremiumDesignTokens.rLg),
            child: Stack(
              children: [
                // Base Content (Icons, Title, Description, Badge)
                _buildCardContent(),

                // In-Card 3D Floating Gold Coins Artwork
                _buildAnimatedCoins(size),

                // In-Card Twinkling Sparkle Stars
                _buildInCardSparkleStars(size),

                // In-Card 3D Top-Left Orange Squircle Sheen
                _buildSquircleSheen(size),

                // Interactive Hover Specular Sheen across entire card
                if (_isHovered) _buildInteractiveSheen(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card Core Typography & Icon Structure
  Widget _buildCardContent() {
    return Column(
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
                gradient: PremiumDesignTokens.gradOrange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.monetization_on_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: PremiumDesignTokens.peachArrowFill,
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

        // Title
        const Text(
          'Coin Toss',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: PremiumDesignTokens.textStrong,
          ),
        ),
        const SizedBox(height: 4),

        // Body
        const Text(
          'Make a quick 50/50 heads-or-tails decision with 3D animation.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: PremiumDesignTokens.textBody,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),

        // Pill Chip: Solid #FFFFFF + 1px border + soft shadow
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.view_in_ar_rounded,
                size: 12,
                color: PremiumDesignTokens.orange500,
              ),
              SizedBox(width: 4),
              Text(
                '3D Animation',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: PremiumDesignTokens.orange500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Clean, layered 3D Golden Coins in the lower-right quadrant
  Widget _buildAnimatedCoins(Size size) {
    final t = _idleController.value * math.pi * 2;
    final coinFloat1 = math.sin(t) * 3.2;
    final coinFloat2 = math.cos(t) * 2.5;

    return Positioned(
      right: -2,
      bottom: -2,
      width: 105,
      height: 90,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Coin 2 (Background, smaller, tilted)
            Positioned(
              right: 8,
              bottom: 12 + coinFloat2,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateZ(-0.35)
                  ..rotateY(0.40)
                  ..rotateX(0.20),
                child: _buildGoldCoinDisc(size: 40),
              ),
            ),

            // Coin 1 (Foreground, larger, golden gleam)
            Positioned(
              right: 32,
              bottom: 18 + coinFloat1,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateZ(0.28)
                  ..rotateY(-0.32)
                  ..rotateX(0.18),
                child: _buildGoldCoinDisc(size: 48, hasStar: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static coins for reduced motion
  Widget _buildStaticCoins() {
    return Positioned(
      right: -2,
      bottom: -2,
      width: 105,
      height: 90,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 8,
              bottom: 12,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(-0.35)
                  ..rotateY(0.40),
                child: _buildGoldCoinDisc(size: 40),
              ),
            ),
            Positioned(
              right: 32,
              bottom: 18,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(0.28)
                  ..rotateY(-0.32),
                child: _buildGoldCoinDisc(size: 48, hasStar: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ultra-sharp vector rendered 3D Gold Coin Disc
  Widget _buildGoldCoinDisc({required double size, bool hasStar = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Color(0xFFFFF2B8), // Bright gold highlight
            Color(0xFFF3BF53), // Warm yellow gold
            Color(0xFFC78810), // Deep coin gold rim
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFFFFE082),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D8D5A08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0x99FFEDB0),
              width: 0.8,
            ),
          ),
          child: Center(
            child: Icon(
              hasStar ? Icons.star_rounded : Icons.monetization_on_rounded,
              size: size * 0.40,
              color: const Color(0xFF8A5A0A),
            ),
          ),
        ),
      ),
    );
  }

  /// Twinkling Sparkle Stars
  Widget _buildInCardSparkleStars(Size size) {
    final t = _sparkleController.value;
    final pulse1 = 0.75 + math.sin(t * math.pi) * 0.45;
    final pulse2 = 0.70 + math.cos(t * math.pi) * 0.40;

    return Stack(
      children: [
        // Star 1 (upper-right card zone): ~70% X, ~38% Y
        Positioned(
          left: size.width * 0.70 - 7,
          top: size.height * 0.38 - 7,
          child: Transform.rotate(
            angle: t * math.pi * 0.5,
            child: Transform.scale(
              scale: pulse1,
              child: _buildSparkleGlint(
                color: const Color(0xFFF28C28),
                glowColor: const Color(0x66F28C28),
              ),
            ),
          ),
        ),

        // Star 2 (bottom-right edge zone): ~92% X, ~76% Y
        Positioned(
          left: size.width * 0.92 - 6,
          top: size.height * 0.76 - 6,
          child: Transform.rotate(
            angle: -t * math.pi * 0.6,
            child: Transform.scale(
              scale: pulse2,
              child: _buildSparkleGlint(
                color: const Color(0xFFFFD54F),
                glowColor: const Color(0x66FFD54F),
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

  /// Specular sheen across the top-left orange squircle
  Widget _buildSquircleSheen(Size size) {
    final progress = _sheenController.value;
    if (progress > 0.6) return const SizedBox.shrink();

    final localProgress = progress / 0.6;
    const squircleSize = 40.0;

    return Positioned(
      left: 14,
      top: 14,
      width: squircleSize,
      height: squircleSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                    Colors.white.withValues(alpha: 0.35),
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
