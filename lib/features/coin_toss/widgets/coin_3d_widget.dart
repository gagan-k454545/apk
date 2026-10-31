import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/shuffle/coin_toss_engine.dart';

/// Super Realistic 3D Gold Coin Toss Widget:
/// - True dual-sided 3D disc model (Heads at +Z front, Tails at -Z back, 13-layer cylindrical rim).
/// - 3D Perspective tumble (rotX flip + rotY gyroscopic wobble + rotZ angular drift).
/// - Kinematic gravity trajectory:
///   1. Thumb flick anticipation dip & squash (0.00..0.05)
///   2. Explosive parabolic ascent + 3D camera zoom (0.05..0.46)
///   3. Slow-motion apex float & specular metallic glint (0.46..0.54)
///   4. Gravitational freefall acceleration (0.54..0.76)
///   5. Sharp surface impact & elastic squash (0.76..0.80)
///   6. 3-stage damped restitution bounces & wobble settling (0.80..1.00)
/// - Exact landing parity: 0° Heads, 180° Tails, 90° No Result (balanced on milled rim).
/// - Dynamic contact ground shadow synchronized with altitude & landing footprint.
/// - Flourish landing burst sparks.
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
            // 1. Super Realistic Dynamic Ground Shadow
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double v = animationController.value;
                final isEdgeLanded = hasResult && plan.isNoResult;

                double translateY = 0.0;
                if (isTossing && !reduceMotion) {
                  if (v <= 0.05) {
                    final p = v / 0.05;
                    translateY = math.sin(p * math.pi) * 8.0;
                  } else if (v <= 0.46) {
                    final p = (v - 0.05) / 0.41;
                    final curveP =
                        const Cubic(0.20, 0.85, 0.35, 1.0).transform(p);
                    translateY = -(curveP * plan.height);
                  } else if (v <= 0.54) {
                    translateY = -plan.height;
                  } else if (v <= 0.76) {
                    final p = (v - 0.54) / 0.22;
                    final curveP =
                        const Cubic(0.55, 0.08, 0.9, 0.65).transform(p);
                    translateY = -plan.height * (1.0 - curveP);
                  } else if (v <= 0.80) {
                    translateY = 0.0;
                  } else {
                    final p = (v - 0.80) / 0.20;
                    double h = 0.0;
                    if (p < 0.45) {
                      h = math.sin((p / 0.45) * math.pi) * 26.0;
                    } else if (p < 0.78) {
                      h = math.sin(((p - 0.45) / 0.33) * math.pi) * 11.0;
                    } else {
                      h = math.sin(((p - 0.78) / 0.22) * math.pi) * 3.5;
                    }
                    translateY = -h;
                  }
                }

                // Altitude ratio: 0.0 (ground) to 1.0 (apex)
                final altitude =
                    (-translateY / (plan.height > 0 ? plan.height : 180.0))
                        .clamp(0.0, 1.0);

                final baseWidth = isEdgeLanded ? 42.0 : 130.0;
                final baseHeight = isEdgeLanded ? 12.0 : 18.0;

                final shadowWidth = baseWidth * (1.0 + altitude * 0.45);
                final shadowHeight = baseHeight * (1.0 + altitude * 0.50);
                final shadowOpacity = (0.45 * (1.0 - altitude * 0.72)).clamp(0.08, 0.48);
                final shadowBlur = 8.0 + (altitude * 32.0);

                return Positioned(
                  bottom: 22,
                  child: Container(
                    width: shadowWidth,
                    height: shadowHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A1C06)
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
                  if (v < 0.76) return const SizedBox.shrink();
                  final p = (v - 0.76) / 0.24;
                  return CustomPaint(
                    size: const Size(270, 270),
                    painter: _CoinSparksPainter(progress: p),
                  );
                },
              ),

            // 3. Super Realistic 3D Animated Gold Coin
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                final double v = animationController.value;

                if (reduceMotion) {
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
                  // Active Cinematic Toss Physics Timeline
                  final totalTurnsDeg = plan.totalTurnsDeg > 0
                      ? plan.totalTurnsDeg
                      : (plan.halfTurns * 180.0);

                  if (v <= 0.05) {
                    // Phase 0: Anticipation compression dip
                    final p = v / 0.05;
                    translateY = math.sin(p * math.pi) * 8.0;
                    scaleY = 1.0 - math.sin(p * math.pi) * 0.06;
                    scaleX = 1.0 + math.sin(p * math.pi) * 0.03;
                    rotXDeg = plan.startAngleDeg;
                  } else if (v <= 0.46) {
                    // Phase 1: Explosive Ascent & 3D Fast Spin
                    final p = (v - 0.05) / 0.41;
                    final curveP =
                        const Cubic(0.20, 0.85, 0.35, 1.0).transform(p);
                    translateY = -(curveP * plan.height);
                    rotXDeg =
                        plan.startAngleDeg + (curveP * totalTurnsDeg * 0.52);
                    rotYDeg = plan.tiltY * math.sin(p * math.pi * 2.5);
                    rotZDeg = plan.driftZ * math.sin(p * math.pi * 2.0);
                    final zoom = 1.0 + math.sin(p * math.pi * 0.5) * 0.28;
                    scaleX = zoom;
                    scaleY = zoom;
                  } else if (v <= 0.54) {
                    // Phase 2: Apex Slow-Motion Float & Specular Gleam
                    final p = (v - 0.46) / 0.08;
                    translateY = -plan.height + math.sin(p * math.pi) * 2.5;
                    rotXDeg = plan.startAngleDeg +
                        (totalTurnsDeg * 0.52) +
                        (p * totalTurnsDeg * 0.08);
                    rotYDeg = plan.tiltY * math.cos(p * math.pi);
                    rotZDeg = plan.driftZ * math.cos(p * math.pi);
                    scaleX = 1.28;
                    scaleY = 1.28;
                  } else if (v <= 0.76) {
                    // Phase 3: Gravitational Freefall
                    final p = (v - 0.54) / 0.22;
                    final curveP =
                        const Cubic(0.55, 0.08, 0.9, 0.65).transform(p);
                    translateY = -plan.height * (1.0 - curveP);
                    rotXDeg = plan.startAngleDeg +
                        (totalTurnsDeg * 0.60) +
                        (curveP * totalTurnsDeg * 0.40);
                    rotYDeg = plan.tiltY * (1.0 - curveP) * 0.25;
                    rotZDeg = plan.driftZ * (1.0 - curveP) * 0.25;
                    final zoom = 1.28 - (curveP * 0.28);
                    scaleX = zoom;
                    scaleY = zoom;
                  } else if (v <= 0.80) {
                    // Phase 4: Ground Impact & Elastic Squash
                    final p = (v - 0.76) / 0.04;
                    translateY = 0.0;
                    rotXDeg = plan.endAngleDeg;
                    scaleY = 1.0 - (math.sin(p * math.pi) * 0.10);
                    scaleX = 1.0 + (math.sin(p * math.pi) * 0.06);
                  } else {
                    // Phase 5: 3-Stage Damped Restitution Bounces
                    final p = (v - 0.80) / 0.20;
                    double bounceH = 0.0;
                    double wobbleX = 0.0;
                    double wobbleY = 0.0;

                    if (p < 0.45) {
                      final bp = p / 0.45;
                      bounceH = math.sin(bp * math.pi) * 26.0;
                      wobbleX = math.sin(bp * math.pi) * 6.5;
                      wobbleY = math.cos(bp * math.pi) * 3.5;
                    } else if (p < 0.78) {
                      final bp = (p - 0.45) / 0.33;
                      bounceH = math.sin(bp * math.pi) * 11.0;
                      wobbleX = -math.sin(bp * math.pi) * 3.0;
                      wobbleY = math.sin(bp * math.pi) * 1.5;
                    } else {
                      final bp = (p - 0.78) / 0.22;
                      bounceH = math.sin(bp * math.pi) * 3.5;
                      wobbleX = math.sin(bp * math.pi) * 1.0;
                      wobbleY = 0.0;
                    }

                    translateY = -bounceH;
                    rotXDeg = plan.endAngleDeg + wobbleX;
                    rotYDeg = wobbleY;
                    scaleX = 1.0;
                    scaleY = 1.0;
                  }
                }

                final radX = rotXDeg * (math.pi / 180.0);
                final radY = rotYDeg * (math.pi / 180.0);
                final radZ = rotZDeg * (math.pi / 180.0);

                final cosX = math.cos(radX);
                final isHeadsFacing = cosX >= 0;
                final shineShift = math.sin(radX * 2.0);

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0016) // Realistic 3D perspective depth
                        ..rotateY(radY)
                        ..rotateZ(radZ)
                        ..rotateX(radX),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. 3D Cylindrical Rim Extrusions (-6px to +6px along Z)
                          ...List.generate(13, (idx) {
                            final z = (idx - 6) * 0.95;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setTranslationRaw(0.0, 0.0, z),
                              child: Container(
                                width: coinSize,
                                height: coinSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    center: Alignment(-0.2, -0.2),
                                    colors: [
                                      Color(0xFFF3C258),
                                      Color(0xFFC78810),
                                      Color(0xFF8A5A0A),
                                    ],
                                    stops: [0.3, 0.7, 1.0],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFFFDF7A),
                                    width: 1.1,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // 2. Active Front Face (Heads) at +Z front
                          if (isHeadsFacing)
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setTranslationRaw(0.0, 0.0, 6.0),
                              child: _GoldCoinFace(
                                face: CoinFace.heads,
                                size: coinSize,
                                shineOffset: shineShift,
                              ),
                            )
                          // 3. Active Back Face (Tails) at -Z back (pre-rotated 180° around X)
                          else
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setTranslationRaw(0.0, 0.0, -6.0)
                                ..rotateX(math.pi),
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

/// Realistic Gold Coin Face:
/// - Rich radial gradient #FFF2C0, #F3C258 52%, #C78810 88%, #8A5A0A
/// - Precision milled rim tick ridges with specular highlight
/// - Inner raised golden bezel
/// - Embossed Crown (Heads) / Embossed Star (Tails) / Milled Rim (No Result)
/// - Moving metallic specular shine sweep
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
          radius: 0.88,
          colors: [
            Color(0xFFFFF2C0), // Bright gold specular highlight
            Color(0xFFF3C258), // Rich lustrous yellow gold at 52%
            Color(0xFFC78810), // Deep coin gold rim
            Color(0xFF8A5A0A), // Shadow edge
          ],
          stops: [0.0, 0.52, 0.88, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x388D5A08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Milled Rim Perimeter Ticks (56 precision ridges)
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
                color: const Color(0xFFFFF0B8).withValues(alpha: 0.95),
                width: 2.2,
              ),
              gradient: const RadialGradient(
                center: Alignment(0.2, 0.2),
                radius: 0.92,
                colors: [
                  Color(0xFFFDE8AA),
                  Color(0xFFE5AE40),
                ],
              ),
            ),
          ),

          // 3. Center Embossed Golden Medallion + Typography
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Embossed Golden Medallion
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF5D0),
                      Color(0xFFD6951A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2E000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isNoResult
                        ? Icons.view_headline_rounded
                        : (isHeads
                            ? Icons.workspace_premium_rounded // Imperial Crown
                            : Icons.stars_rounded), // Star
                    size: 32,
                    color: const Color(0xFF7A4E06),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Crisp Small-Caps Face Title
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
                  begin: Alignment(-1.2 + (shineOffset * 0.85), -1.0),
                  end: Alignment(1.2 + (shineOffset * 0.85), 1.0),
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.40),
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

      final pOuter =
          Offset(center.dx + radius * cosA, center.dy + radius * sinA);
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
    const count = 12;
    final easeP = Curves.easeOutCubic.transform(progress);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final sparkPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: alpha)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (i % 2 == 0 ? 0.2 : -0.15);
      final distStart = 78.0 + (easeP * 24.0);
      final distEnd = distStart + 10.0 + (easeP * 14.0);

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
