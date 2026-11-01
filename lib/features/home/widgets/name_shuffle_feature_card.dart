import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/pressable_scale.dart';

/// The 3D Animated Name Shuffle Feature Card:
/// - Re-engineered with 100% native Flutter vector layout for flawless responsiveness
///   and razor-sharp typography across all device screen sizes.
/// - 3D Perspective Tilt: Interactive mouse hover & touch perspective tilt with specular light reflection.
/// - 3D Idle Breathing: Continuous gentle harmonic floating and micro-tilt.
/// - In-Card 3D Name Cards: Crisp, layered 3D floating name cards with perspective tilt and drop shadows.
/// - In-Card Sparkle Stars: Twinkling 4-point emerald/gold stars pulsing and rotating with light halos.
/// - 3D Green Squircle Gleam: Periodic diagonal specular sheen sweeping across the top-left shuffle icon.
/// - Tactile interaction: Pressable scale depth and instant haptic feedback.
/// - Strict dimensional and layout parity with CoinTossFeatureCard for flawless row alignment.
class NameShuffleFeatureCard extends StatefulWidget {
  const NameShuffleFeatureCard({
    super.key,
    required this.onTap,
    this.height = 195,
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
      container: true,
      excludeSemantics: true,
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
      padding: const EdgeInsets.all(14),
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
        child: Stack(
          children: [
            _buildCardContent(),
            _buildStaticCards(),
          ],
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
              children: [
                // Base Content (Icons, Title, Description, Badge)
                _buildCardContent(),

                // In-Card 3D Floating Name Cards Artwork
                _buildAnimatedCards(size),

                // In-Card Twinkling Sparkle Stars
                _buildInCardSparkleStars(size),

                // In-Card 3D Top-Left Green Squircle Sheen
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
                gradient: PremiumDesignTokens.gradPrimary,
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
                  Icons.shuffle_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: PremiumDesignTokens.mintArrowFill,
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

        // Title - Always 100% visible, sharp & never cropped
        const Text(
          'Name Shuffle',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: PremiumDesignTokens.textStrong,
          ),
        ),
        const SizedBox(height: 4),

        // Body Description
        const Text(
          'Randomize a list of names with Fisher-Yates algorithm.',
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
                Icons.bolt_rounded,
                size: 12,
                color: PremiumDesignTokens.green700,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Fair & Instant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.green800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Clean, layered 3D Floating Name Cards in the lower-right quadrant
  Widget _buildAnimatedCards(Size size) {
    final t = _idleController.value * math.pi * 2;
    final cardFloat1 = math.sin(t) * 3.2;
    final cardFloat2 = math.cos(t) * 2.4;

    return Positioned(
      right: -4,
      bottom: -4,
      width: 106,
      height: 94,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Card 2 (Background, smaller, tilted)
            Positioned(
              right: 6,
              bottom: 18 + cardFloat2,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateZ(-0.24)
                  ..rotateY(0.28)
                  ..rotateX(0.14),
                child: _buildMiniNameCard(
                  avatarColor: PremiumDesignTokens.teal600,
                  avatarBg: PremiumDesignTokens.teal100,
                  width: 66,
                ),
              ),
            ),

            // Card 1 (Foreground, larger, emerald highlight)
            Positioned(
              right: 26,
              bottom: 10 + cardFloat1,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateZ(0.16)
                  ..rotateY(-0.22)
                  ..rotateX(0.10),
                child: _buildMiniNameCard(
                  avatarColor: PremiumDesignTokens.green800,
                  avatarBg: PremiumDesignTokens.green100,
                  width: 72,
                  isHero: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static cards for reduced motion
  Widget _buildStaticCards() {
    return Positioned(
      right: -4,
      bottom: -4,
      width: 106,
      height: 94,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 6,
              bottom: 18,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(-0.24)
                  ..rotateY(0.28),
                child: _buildMiniNameCard(
                  avatarColor: PremiumDesignTokens.teal600,
                  avatarBg: PremiumDesignTokens.teal100,
                  width: 66,
                ),
              ),
            ),
            Positioned(
              right: 26,
              bottom: 10,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(0.16)
                  ..rotateY(-0.22),
                child: _buildMiniNameCard(
                  avatarColor: PremiumDesignTokens.green800,
                  avatarBg: PremiumDesignTokens.green100,
                  width: 72,
                  isHero: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ultra-sharp vector rendered 3D Mini Name Card with abstract placeholder bars (no dummy names)
  Widget _buildMiniNameCard({
    required Color avatarColor,
    required Color avatarBg,
    required double width,
    bool isHero = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHero
              ? PremiumDesignTokens.green600.withValues(alpha: 0.35)
              : const Color(0x221B4332),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x181B4332),
            blurRadius: isHero ? 8 : 5,
            offset: Offset(0, isHero ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                size: 10,
                color: avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4.5,
                  width: width * 0.45,
                  decoration: BoxDecoration(
                    color: isHero
                        ? PremiumDesignTokens.green700.withValues(alpha: 0.70)
                        : PremiumDesignTokens.textStrong.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 2.5),
                Container(
                  height: 3.5,
                  width: width * 0.28,
                  decoration: BoxDecoration(
                    color: isHero
                        ? PremiumDesignTokens.green600.withValues(alpha: 0.40)
                        : PremiumDesignTokens.textMuted.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
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

    return Positioned(
      left: 14,
      top: 14,
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Transform.translate(
          offset: Offset(
            -40.0 + localProgress * (40.0 * 2.2),
            -40.0 + localProgress * (40.0 * 2.2),
          ),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 18,
              height: 100,
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
