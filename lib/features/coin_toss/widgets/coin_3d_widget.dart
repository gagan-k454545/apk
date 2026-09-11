import 'dart:math';
import 'package:flutter/material.dart';

class Coin3DWidget extends StatelessWidget {
  const Coin3DWidget({
    super.key,
    required this.animationController,
    required this.isHeadsResult,
    required this.isAnimating,
    required this.hasResult,
  });

  final AnimationController animationController;
  final bool isHeadsResult;
  final bool isAnimating;
  final bool hasResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow underneath
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final value = animationController.value;

                  double shadowScale = 1.0;
                  double shadowOpacity = 0.35;
                  double shadowBlur = 16.0;

                  if (value > 0 && value <= 0.15) {
                    // Prep downward
                    final p = value / 0.15;
                    shadowScale = 1.0 + (p * 0.25);
                    shadowOpacity = 0.35 + (p * 0.25);
                    shadowBlur = 16.0 - (p * 6.0);
                  } else if (value > 0.15 && value <= 0.50) {
                    // Launch high
                    final p = (value - 0.15) / 0.35;
                    shadowScale = 1.25 - (p * 0.85);
                    shadowOpacity = 0.60 - (p * 0.45);
                    shadowBlur = 10.0 + (p * 30.0);
                  } else if (value > 0.50 && value <= 0.82) {
                    // Descend
                    final p = (value - 0.50) / 0.32;
                    shadowScale = 0.4 + (p * 0.6);
                    shadowOpacity = 0.15 + (p * 0.25);
                    shadowBlur = 40.0 - (p * 24.0);
                  } else if (value > 0.82) {
                    shadowScale = 1.0;
                    shadowOpacity = 0.35;
                    shadowBlur = 16.0;
                  }

                  return Positioned(
                    bottom: 15,
                    child: Container(
                      width: 140 * shadowScale,
                      height: 22 * shadowScale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: shadowOpacity)
                                : theme.colorScheme.primary
                                    .withValues(alpha: shadowOpacity * 0.6),
                            blurRadius: shadowBlur,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Particle Confetti Burst on Result Landing
              if (hasResult)
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    final value = animationController.value;
                    if (value < 0.82) return const SizedBox.shrink();

                    final p = (value - 0.82) / 0.18;
                    return CustomPaint(
                      size: const Size(260, 260),
                      painter: _ConfettiPainter(
                        progress: p,
                        isHeads: isHeadsResult,
                        primaryColor: theme.colorScheme.primary,
                        tertiaryColor: theme.colorScheme.tertiary,
                      ),
                    );
                  },
                ),

              // 3D Animated Coin
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final v = animationController.value;

                  // 1. Calculate Vertical Displacement (Y Translation)
                  double translateY = 0.0;
                  if (v <= 0.15) {
                    // Phase 1: Prep dip downward
                    final p = v / 0.15;
                    translateY = p * 16.0;
                  } else if (v <= 0.50) {
                    // Phase 2: Launch upward
                    final p = (v - 0.15) / 0.35;
                    final curveP = Curves.easeOutQuad.transform(p);
                    translateY = 16.0 - (curveP * 216.0); // Up to -200px
                  } else if (v <= 0.82) {
                    // Phase 3 & 4: Landing descent
                    final p = (v - 0.50) / 0.32;
                    final curveP = Curves.easeInQuad.transform(p);
                    translateY = -200.0 + (curveP * 200.0);
                  } else if (v <= 0.90) {
                    // Phase 4: Bounce
                    final p = (v - 0.82) / 0.08;
                    translateY = -sin(p * pi) * 14.0;
                  } else {
                    translateY = 0.0;
                  }

                  // 2. Calculate Scale
                  double scaleX = 1.0;
                  double scaleY = 1.0;
                  if (v <= 0.15) {
                    final p = v / 0.15;
                    scaleX = 1.0 - (p * 0.08);
                    scaleY = scaleX;
                  } else if (v <= 0.50) {
                    final p = (v - 0.15) / 0.35;
                    scaleX = 0.92 + (p * 0.30); // scale up to 1.22
                    scaleY = scaleX;
                  } else if (v <= 0.82) {
                    final p = (v - 0.50) / 0.32;
                    scaleX = 1.22 - (p * 0.22);
                    scaleY = scaleX;
                  } else if (v <= 0.90) {
                    // Squash & bounce on land
                    final p = (v - 0.82) / 0.08;
                    scaleY = 1.0 - (sin(p * pi) * 0.12);
                    scaleX = 1.0 + (sin(p * pi) * 0.08);
                  }

                  // 3. Calculate 3D Rotation Angle (X-Axis)
                  // Heads = multiple of 2pi (e.g. 10 * pi = 5 full flips)
                  // Tails = odd multiple of pi (e.g. 11 * pi = 5.5 full flips)
                  final targetFlips = isHeadsResult ? 10.0 : 11.0;
                  final totalTargetAngle = targetFlips * pi;

                  double currentAngle = 0.0;
                  if (v <= 0.15) {
                    currentAngle = 0.0;
                  } else if (v <= 0.85) {
                    final p = (v - 0.15) / 0.70;
                    final curveP = const Cubic(0.25, 0.1, 0.25, 1.0).transform(p);
                    currentAngle = curveP * totalTargetAngle;
                  } else {
                    currentAngle = totalTargetAngle;
                  }

                  // Face Determination using cos(angle)
                  final cosVal = cos(currentAngle);
                  final showHeads = cosVal >= 0;

                  // Specular Shine Gradient Shift
                  final shineOffset = sin(currentAngle);

                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scaleX: scaleX,
                      scaleY: scaleY,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0018) // Perspective 3D
                          ..rotateX(currentAngle),
                        child: showHeads
                            ? _CoinFace(
                                isHeads: true,
                                shineOffset: shineOffset,
                                theme: theme,
                              )
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationX(pi),
                                child: _CoinFace(
                                  isHeads: false,
                                  shineOffset: shineOffset,
                                  theme: theme,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({
    required this.isHeads,
    required this.shineOffset,
    required this.theme,
  });

  final bool isHeads;
  final double shineOffset;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    final baseGradientColors = isHeads
        ? [
            const Color(0xFFF6D365),
            const Color(0xFFFDA085),
            const Color(0xFFF6D365),
          ]
        : [
            const Color(0xFFE0C3FC),
            const Color(0xFF8EC5FC),
            const Color(0xFFE0C3FC),
          ];

    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: baseGradientColors,
          begin: Alignment(-1.0 + shineOffset, -1.0),
          end: Alignment(1.0 + shineOffset, 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: (isHeads ? const Color(0xFFFDA085) : primary)
                .withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B).withValues(alpha: 0.85),
            border: Border.all(
              color: (isHeads ? const Color(0xFFF6D365) : const Color(0xFFE0C3FC))
                  .withValues(alpha: 0.8),
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Milled edge dotted inner ring
              CustomPaint(
                size: const Size(140, 140),
                painter: _CoinEdgePainter(
                  color: (isHeads ? const Color(0xFFF6D365) : const Color(0xFFE0C3FC))
                      .withValues(alpha: 0.4),
                ),
              ),

              // Emblem & Label
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isHeads
                            ? [const Color(0xFFF6D365), const Color(0xFFFDA085)]
                            : [primary, tertiary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isHeads ? const Color(0xFFF6D365) : primary)
                              .withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      isHeads ? Icons.workspace_premium : Icons.stars_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHeads ? 'HEADS' : 'TAILS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: isHeads
                          ? const Color(0xFFF6D365)
                          : const Color(0xFFE0C3FC),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinEdgePainter extends CustomPainter {
  _CoinEdgePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const dotCount = 36;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * pi) / dotCount;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoinEdgePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.isHeads,
    required this.primaryColor,
    required this.tertiaryColor,
  });

  final double progress;
  final bool isHeads;
  final Color primaryColor;
  final Color tertiaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42); // Seeded for deterministic beautiful particle layout

    final colors = isHeads
        ? [
            const Color(0xFFF6D365),
            const Color(0xFFFDA085),
            Colors.amber,
            Colors.orangeAccent,
          ]
        : [
            primaryColor,
            tertiaryColor,
            const Color(0xFFE0C3FC),
            Colors.lightBlueAccent,
          ];

    const particleCount = 28;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * pi) / particleCount + (random.nextDouble() * 0.2);
      final distance = (70 + (random.nextDouble() * 60)) * progress;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);

      final particleSize = (3.0 + random.nextDouble() * 4.0) * (1.0 - progress * 0.5);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
