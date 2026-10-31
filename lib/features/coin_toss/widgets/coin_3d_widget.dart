import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/shuffle/coin_toss_engine.dart';

/// Premium 3D Gold Coin Toss Widget matching Section 3 & 4:
/// - 150px size
/// - Rich radial gold gradient: #FCE29A, #E9B44C 55%, #C98A14
/// - Milled rim ticks & inner raised ring
/// - Crown emblem on Heads, Ringed Star on Tails + small caps label
/// - 3D disc stacked edge depth (translateZ -6px..+6px)
/// - Moving metallic specular shine sweep
/// - Full physics-feel animation (anticipation dip, launch, apex scale 1.25,
///   fall, land squash, damped bounces, settling on exact parity)
/// - Synchronized dynamic shadow & landing sparks flourish
class Coin3DWidget extends StatelessWidget {
  const Coin3DWidget({
    super.key,
    required this.animationController,
    required this.plan,
    required this.isTossing,
    required this.hasResult,
    required this.onTap,
    this.coinSize = 150.0,
  });

  final AnimationController animationController;
  final TossPlan plan;
  final bool isTossing;
  final bool hasResult;
  final VoidCallback onTap;
  final double coinSize;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: isTossing ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Soft Elliptical Ground Shadow under the coin
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double v = animationController.value;

                double shadowScale = 1.0;
                double shadowOpacity = 0.35;
                double shadowBlur = 16.0;

                if (isTossing && !reduceMotion) {
                  if (v <= 0.05) {
                    // Anticipation
                    final p = v / 0.05;
                    shadowScale = 1.0 + (p * 0.1);
                    shadowOpacity = 0.35 + (p * 0.1);
                    shadowBlur = 16.0 - (p * 4.0);
                  } else if (v <= 0.45) {
                    // Launch to apex
                    final p = (v - 0.05) / 0.40;
                    final curveP = const Cubic(0.2, 0.7, 0.3, 1.0).transform(p);
                    shadowScale = 1.1 - (curveP * 0.55); // down to 0.55
                    shadowOpacity = 0.45 - (curveP * 0.27); // down to 0.18
                    shadowBlur = 12.0 + (curveP * 26.0); // up to 38.0
                  } else if (v <= 0.78) {
                    // Fall to ground
                    final p = (v - 0.45) / 0.33;
                    final curveP = const Cubic(0.5, 0.0, 0.9, 0.5).transform(p);
                    shadowScale = 0.55 + (curveP * 0.45);
                    shadowOpacity = 0.18 + (curveP * 0.17);
                    shadowBlur = 38.0 - (curveP * 22.0);
                  } else {
                    // Land & bounces
                    shadowScale = 1.0;
                    shadowOpacity = 0.35;
                    shadowBlur = 16.0;
                  }
                }

                return Positioned(
                  bottom: 22,
                  child: Container(
                    width: 135 * shadowScale,
                    height: 20 * shadowScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A1F08).withValues(alpha: shadowOpacity),
                          blurRadius: shadowBlur,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 2. Landing Flourish Sparks (6 to 8 tiny gold/orange spark dashes burst on landing)
            if (hasResult)
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final v = animationController.value;
                  if (v < 0.78) return const SizedBox.shrink();
                  final p = (v - 0.78) / 0.22;
                  return CustomPaint(
                    size: const Size(260, 260),
                    painter: _CoinSparksPainter(progress: p),
                  );
                },
              ),

            // 3. 3D Animated Gold Coin
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double v = animationController.value;

                if (reduceMotion) {
                  // Reduced motion fallback: 250ms crossfade flip
                  final currentFace = isTossing
                      ? (v > 0.5 ? plan.result : plan.startFace)
                      : (hasResult ? plan.result : plan.startFace);
                  final isHeads = currentFace == CoinFace.heads;

                  return _GoldCoinFace(
                    isHeads: isHeads,
                    size: coinSize,
                    shineOffset: 0.0,
                  );
                }

                double translateY = 0.0;
                double scaleX = 1.0;
                double scaleY = 1.0;
                double rotXDeg = plan.startAngleDeg;
                double rotYDeg = 0.0;
                double rotZDeg = 0.0;

                if (!isTossing && !hasResult) {
                  // Idle resting state
                  rotXDeg = plan.startAngleDeg;
                } else if (!isTossing && hasResult) {
                  // Settled result state
                  rotXDeg = plan.endAngleDeg;
                } else {
                  // Active Toss Physics Timeline
                  final totalTurnsDeg = plan.halfTurns * 180.0;

                  if (v <= 0.05) {
                    // 0.00 to 0.05: Anticipation dip
                    final p = v / 0.05;
                    translateY = p * 6.0;
                    scaleY = 1.0 - (p * 0.04); // .96
                    scaleX = 1.0 + (p * 0.02);
                    rotXDeg = plan.startAngleDeg;
                  } else if (v <= 0.45) {
                    // 0.05 to 0.45: Launch to apex
                    final p = (v - 0.05) / 0.40;
                    final curveP = const Cubic(0.2, 0.7, 0.3, 1.0).transform(p);
                    translateY = 6.0 - (curveP * (plan.height + 6.0));
                    rotXDeg = plan.startAngleDeg + (curveP * totalTurnsDeg * 0.55);
                    rotYDeg = plan.tiltY * math.sin(p * math.pi);
                    rotZDeg = plan.driftZ * math.sin(p * math.pi);
                    final scaleElev = 1.0 + (math.sin(p * math.pi * 0.5) * 0.25);
                    scaleX = scaleElev;
                    scaleY = scaleElev;
                  } else if (v <= 0.78) {
                    // 0.45 to 0.78: Fall to ground
                    final p = (v - 0.45) / 0.33;
                    final curveP = const Cubic(0.5, 0.0, 0.9, 0.5).transform(p);
                    translateY = -plan.height + (curveP * plan.height);
                    rotXDeg = plan.startAngleDeg +
                        (totalTurnsDeg * 0.55) +
                        (curveP * totalTurnsDeg * 0.45);
                    rotYDeg = plan.tiltY * (1.0 - curveP);
                    rotZDeg = plan.driftZ * (1.0 - curveP);
                    final scaleElev = 1.25 - (curveP * 0.25);
                    scaleX = scaleElev;
                    scaleY = scaleElev;
                  } else if (v <= 0.82) {
                    // 0.78 to 0.82: Land squash
                    final p = (v - 0.78) / 0.04;
                    translateY = 0.0;
                    rotXDeg = plan.endAngleDeg;
                    scaleY = 1.0 - (math.sin(p * math.pi) * 0.06); // .94
                    scaleX = 1.0 + (math.sin(p * math.pi) * 0.04); // 1.04
                  } else {
                    // 0.82 to 1.00: Damped bounces (heights ~26px, 11px, 4px)
                    final p = (v - 0.82) / 0.18;
                    double bounceHeight = 0.0;
                    double wobbleDeg = 0.0;

                    if (plan.bounces >= 3) {
                      if (p < 0.45) {
                        final bp = p / 0.45;
                        bounceHeight = math.sin(bp * math.pi) * 26.0;
                        wobbleDeg = math.sin(bp * math.pi) * 6.0;
                      } else if (p < 0.78) {
                        final bp = (p - 0.45) / 0.33;
                        bounceHeight = math.sin(bp * math.pi) * 11.0;
                        wobbleDeg = -math.sin(bp * math.pi) * 3.0;
                      } else {
                        final bp = (p - 0.78) / 0.22;
                        bounceHeight = math.sin(bp * math.pi) * 4.0;
                        wobbleDeg = math.sin(bp * math.pi) * 1.0;
                      }
                    } else {
                      if (p < 0.60) {
                        final bp = p / 0.60;
                        bounceHeight = math.sin(bp * math.pi) * 24.0;
                        wobbleDeg = math.sin(bp * math.pi) * 5.0;
                      } else {
                        final bp = (p - 0.60) / 0.40;
                        bounceHeight = math.sin(bp * math.pi) * 8.0;
                        wobbleDeg = -math.sin(bp * math.pi) * 2.0;
                      }
                    }

                    translateY = -bounceHeight;
                    rotXDeg = plan.endAngleDeg + wobbleDeg;
                    scaleX = 1.0;
                    scaleY = 1.0;
                  }
                }

                final radX = rotXDeg * (math.pi / 180.0);
                final radY = rotYDeg * (math.pi / 180.0);
                final radZ = rotZDeg * (math.pi / 180.0);

                // Parity face check: cos(radX) >= 0 is Heads, < 0 is Tails
                final cosVal = math.cos(radX);
                final isHeadsFacing = cosVal >= 0;
                final shineShift = math.sin(radX);

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0011) // 3D Perspective (900px equivalent)
                        ..rotateY(radY)
                        ..rotateZ(radZ)
                        ..rotateX(radX),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 3D Rim Depth Disc Layers (-6px to +6px)
                          ...List.generate(7, (idx) {
                            final z = (idx - 3) * 1.8;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..setTranslationRaw(0.0, 0.0, z),
                              child: Container(
                                width: coinSize,
                                height: coinSize,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFC78B18), // Darker edge gold
                                ),
                              ),
                            );
                          }),

                          // Active Facing Side (Heads or Tails)
                          isHeadsFacing
                              ? _GoldCoinFace(
                                  isHeads: true,
                                  size: coinSize,
                                  shineOffset: shineShift,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationX(math.pi),
                                  child: _GoldCoinFace(
                                    isHeads: false,
                                    size: coinSize,
                                    shineOffset: shineShift,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold Coin Face matching Section 3:
/// - Radial gradient #FCE29A, #E9B44C 55%, #C98A14
/// - Custom milled rim ticks
/// - Inner raised golden bezel
/// - Embossed Crown (Heads) / Ringed Star (Tails)
/// - Moving specular highlight overlay
class _GoldCoinFace extends StatelessWidget {
  const _GoldCoinFace({
    required this.isHeads,
    required this.size,
    required this.shineOffset,
  });

  final bool isHeads;
  final double size;
  final double shineOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Color(0xFFFCE29A), // Gold highlight
            Color(0xFFE9B44C), // Rich yellow gold at 55%
            Color(0xFFC98A14), // Deep coin gold rim
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33A66A0D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Milled Rim Perimeter Ticks
          CustomPaint(
            size: Size(size, size),
            painter: const _MilledRimPainter(tickCount: 56),
          ),

          // 2. Inner Raised Bezel Ring
          Container(
            width: size - 24,
            height: size - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFCE39E).withValues(alpha: 0.9),
                width: 2.2,
              ),
              gradient: const RadialGradient(
                center: Alignment(0.2, 0.2),
                radius: 0.9,
                colors: [
                  Color(0xFFFDE8AA),
                  Color(0xFFE5AE40),
                ],
              ),
            ),
          ),

          // 3. Center Emblem + Small Caps Face Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Embossed Golden Emblem
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF2C2),
                      Color(0xFFD6951A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isHeads
                        ? Icons.workspace_premium_rounded // Crown emblem
                        : Icons.stars_rounded, // Ringed star emblem
                    size: 30,
                    color: const Color(0xFF7A4E06), // Embossed antique gold
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Small Caps Face Title
              Text(
                isHeads ? 'HEADS' : 'TAILS',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: Color(0xFF6B4302), // Deep engraved bronze-gold
                  shadows: [
                    Shadow(
                      color: Color(0x80FFE8A8),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 4. Moving Metallic Specular Highlight Sweep
          ClipOval(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.2 + (shineOffset * 0.8), -1.0),
                  end: Alignment(1.2 + (shineOffset * 0.8), 1.0),
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.35, 0.50, 0.65],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise Milled Coin Rim Tick Painter (56 fine edge ticks)
class _MilledRimPainter extends CustomPainter {
  const _MilledRimPainter({required this.tickCount});

  final int tickCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 1.5;
    const tickLength = 5.0;

    final paintLight = Paint()
      ..color = const Color(0xFFFFF0B8).withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final paintDark = Paint()
      ..color = const Color(0xFF9E680E).withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < tickCount; i++) {
      final angle = (i * 2 * math.pi) / tickCount;
      final p1 = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      // Dual-tone tick for 3D metallic teeth effect
      canvas.drawLine(p1, p2, i.isEven ? paintLight : paintDark);
    }
  }

  @override
  bool shouldRepaint(covariant _MilledRimPainter oldDelegate) =>
      oldDelegate.tickCount != tickCount;
}

/// Landing Sparks Dash Particle Burst (Section 4)
class _CoinSparksPainter extends CustomPainter {
  _CoinSparksPainter({required this.progress});

  final double progress;
  static final math.Random _rng = math.Random(1337);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 2.4 * (1.0 - progress)
      ..strokeCap = StrokeCap.round;

    const sparkCount = 8;
    for (int i = 0; i < sparkCount; i++) {
      final baseAngle = (i * 2 * math.pi) / sparkCount;
      final jitter = (_rng.nextDouble() - 0.5) * 0.2;
      final angle = baseAngle + jitter;

      final startDist = 78.0 + (progress * 38.0);
      final endDist = startDist + 8.0 + (progress * 6.0);

      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = i.isEven
          ? const Color(0xFFF2C75C).withValues(alpha: alpha)
          : const Color(0xFFF28C28).withValues(alpha: alpha);

      final p1 = Offset(
        center.dx + (startDist * math.cos(angle)),
        center.dy + (startDist * math.sin(angle)),
      );
      final p2 = Offset(
        center.dx + (endDist * math.cos(angle)),
        center.dy + (endDist * math.sin(angle)),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoinSparksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
