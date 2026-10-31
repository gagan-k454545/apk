import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/shuffle/coin_toss_engine.dart';

/// Premium 3D Gold Coin Toss Widget:
/// - 150px size
/// - Rich radial gold gradient: #FCE29A, #E9B44C 55%, #C98A14
/// - Milled rim ticks & inner raised ring
/// - Crown emblem on Heads, Ringed Star on Tails, Standing Rim on No Result
/// - 3D disc stacked edge depth (translateZ -6px..+6px)
/// - Moving metallic specular shine sweep
/// - Full physics-feel animation (anticipation dip, launch, apex scale 1.25,
///   fall, land squash, damped bounces, settling on exact parity: 0° Heads, 180° Tails, 90° No Result)
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
            // 1. Soft Ground Shadow under the coin
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double v = animationController.value;

                double shadowScale = 1.0;
                double shadowOpacity = 0.35;
                double shadowBlur = 16.0;

                final isEdgeLanded = hasResult && plan.isNoResult;

                if (isTossing && !reduceMotion) {
                  if (v <= 0.05) {
                    final p = v / 0.05;
                    shadowScale = 1.0 + (p * 0.1);
                    shadowOpacity = 0.35 + (p * 0.1);
                    shadowBlur = 16.0 - (p * 4.0);
                  } else if (v <= 0.45) {
                    final p = (v - 0.05) / 0.40;
                    final curveP = const Cubic(0.2, 0.7, 0.3, 1.0).transform(p);
                    shadowScale = 1.1 - (curveP * 0.55);
                    shadowOpacity = 0.45 - (curveP * 0.27);
                    shadowBlur = 12.0 + (curveP * 26.0);
                  } else if (v <= 0.78) {
                    final p = (v - 0.45) / 0.33;
                    final curveP = const Cubic(0.5, 0.0, 0.9, 0.5).transform(p);
                    shadowScale = 0.55 + (curveP * 0.45);
                    shadowOpacity = 0.18 + (curveP * 0.17);
                    shadowBlur = 38.0 - (curveP * 22.0);
                  } else {
                    shadowScale = 1.0;
                    shadowOpacity = 0.35;
                    shadowBlur = 16.0;
                  }
                }

                // If standing on edge (No Result), shadow is narrow directly under the rim
                final baseWidth = isEdgeLanded ? 48.0 : 135.0;
                final baseHeight = isEdgeLanded ? 14.0 : 20.0;

                return Positioned(
                  bottom: 22,
                  child: Container(
                    width: baseWidth * shadowScale,
                    height: baseHeight * shadowScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A1F08)
                              .withValues(alpha: shadowOpacity),
                          blurRadius: shadowBlur,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 2. Landing Flourish Sparks
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
                  // Reduced motion fallback: crossfade flip
                  final currentFace = isTossing
                      ? (v > 0.5 ? plan.result : plan.startFace)
                      : (hasResult ? plan.result : plan.startFace);

                  return _GoldCoinFace(
                    face: currentFace,
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
                  rotXDeg = plan.startAngleDeg;
                } else if (!isTossing && hasResult) {
                  rotXDeg = plan.endAngleDeg;
                } else {
                  // Active Toss Physics Timeline
                  final totalTurnsDeg = plan.totalTurnsDeg > 0
                      ? plan.totalTurnsDeg
                      : (plan.halfTurns * 180.0);

                  if (v <= 0.05) {
                    final p = v / 0.05;
                    translateY = p * 6.0;
                    scaleY = 1.0 - (p * 0.04);
                    scaleX = 1.0 + (p * 0.02);
                    rotXDeg = plan.startAngleDeg;
                  } else if (v <= 0.45) {
                    final p = (v - 0.05) / 0.40;
                    final curveP =
                        const Cubic(0.2, 0.7, 0.3, 1.0).transform(p);
                    translateY = 6.0 - (curveP * (plan.height + 6.0));
                    rotXDeg =
                        plan.startAngleDeg + (curveP * totalTurnsDeg * 0.55);
                    rotYDeg = plan.tiltY * math.sin(p * math.pi);
                    rotZDeg = plan.driftZ * math.sin(p * math.pi);
                    final scaleElev =
                        1.0 + (math.sin(p * math.pi * 0.5) * 0.25);
                    scaleX = scaleElev;
                    scaleY = scaleElev;
                  } else if (v <= 0.78) {
                    final p = (v - 0.45) / 0.33;
                    final curveP =
                        const Cubic(0.5, 0.0, 0.9, 0.5).transform(p);
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
                    final p = (v - 0.78) / 0.04;
                    translateY = 0.0;
                    rotXDeg = plan.endAngleDeg;
                    scaleY = 1.0 - (math.sin(p * math.pi) * 0.06);
                    scaleX = 1.0 + (math.sin(p * math.pi) * 0.04);
                  } else {
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

                // Parity face check:
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
                        ..setEntry(3, 2, 0.0011) // 3D Perspective
                        ..rotateY(radY)
                        ..rotateZ(radZ)
                        ..rotateX(radX),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 3D Rim Depth Disc Layers (-7px to +7px)
                          ...List.generate(9, (idx) {
                            final z = (idx - 4) * 1.8;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setTranslationRaw(0.0, 0.0, z),
                              child: Container(
                                width: coinSize,
                                height: coinSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC78B18),
                                  border: Border.all(
                                    color: const Color(0xFFE9B44C),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Active Facing Side (Heads or Tails)
                          isHeadsFacing
                              ? _GoldCoinFace(
                                  face: CoinFace.heads,
                                  size: coinSize,
                                  shineOffset: shineShift,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationX(math.pi),
                                  child: _GoldCoinFace(
                                    face: CoinFace.tails,
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

/// Gold Coin Face:
/// - Radial gradient #FCE29A, #E9B44C 55%, #C98A14
/// - Custom milled rim ticks
/// - Inner raised golden bezel
/// - Embossed Crown (Heads) / Ringed Star (Tails) / Milled Edge (No Result)
class _GoldCoinFace extends StatelessWidget {
  const _GoldCoinFace({
    required this.face,
    required this.size,
    required this.shineOffset,
  });

  final CoinFace face;
  final double size;
  final double shineOffset;

  @override
  Widget build(BuildContext context) {
    final isHeads = face == CoinFace.heads;
    final isNoResult = face == CoinFace.noResult;

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
                    isNoResult
                        ? Icons.view_headline_rounded
                        : (isHeads
                            ? Icons.workspace_premium_rounded // Crown
                            : Icons.stars_rounded), // Star
                    size: 30,
                    color: const Color(0xFF7A4E06),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Small Caps Face Title
              Text(
                isNoResult ? 'NO RESULT' : (isHeads ? 'HEADS' : 'TAILS'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: Color(0xFF6B4302),
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

/// Custom painter for the 56 milled coin rim ridges
class _MilledRimPainter extends CustomPainter {
  const _MilledRimPainter({required this.tickCount});

  final int tickCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const tickLen = 6.5;

    final paintTick = Paint()
      ..color = const Color(0xFF8B5E0E).withValues(alpha: 0.55)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final paintTickHighlight = Paint()
      ..color = const Color(0xFFFFF0B8).withValues(alpha: 0.70)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < tickCount; i++) {
      final angle = (i * 2 * math.pi) / tickCount;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);

      final pOuter = Offset(center.dx + radius * cosA, center.dy + radius * sinA);
      final pInner = Offset(
        center.dx + (radius - tickLen) * cosA,
        center.dy + (radius - tickLen) * sinA,
      );

      canvas.drawLine(pInner, pOuter, paintTick);

      final pOuterHL = Offset(
        center.dx + radius * cosA + 0.5,
        center.dy + radius * sinA + 0.5,
      );
      final pInnerHL = Offset(
        center.dx + (radius - tickLen) * cosA + 0.5,
        center.dy + (radius - tickLen) * sinA + 0.5,
      );
      canvas.drawLine(pInnerHL, pOuterHL, paintTickHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _MilledRimPainter oldDelegate) =>
      oldDelegate.tickCount != tickCount;
}

/// Flourish landing burst sparks painter (bursts when coin hits stage)
class _CoinSparksPainter extends CustomPainter {
  const _CoinSparksPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2 + 10);
    const count = 8;
    final easeP = Curves.easeOutCubic.transform(progress);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final sparkPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: alpha)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (i % 2 == 0 ? 0.2 : -0.15);
      final distStart = 78.0 + (easeP * 20.0);
      final distEnd = distStart + 10.0 + (easeP * 12.0);

      final p1 = Offset(
        center.dx + distStart * math.cos(angle),
        center.dy + (distStart * 0.45) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + distEnd * math.cos(angle),
        center.dy + (distEnd * 0.45) * math.sin(angle),
      );

      canvas.drawLine(p1, p2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoinSparksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
