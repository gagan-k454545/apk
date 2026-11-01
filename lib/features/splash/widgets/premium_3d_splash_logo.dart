import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A senior-motion-designed, cinematic 3D splash & loading animation for Shuffle Master.
///
/// Implements:
/// - Exact brand palette: Warm sand/cream background, dark forest & emerald green accents
/// - True 3D perspective floating physics with realistic pitch, yaw, and roll
/// - Multi-layer responsive contact, drop, and ambient diffusion shadows
/// - Subtle orbital randomization energy ring with flowing micro-nodes
/// - Glassy diagonal light shimmer pass across the 3D arrow facets
/// - Two sequential 4-point diamond specular micro-glints with rotation
/// - Understated, luxury brand typography and breathing loading indicator
/// - 100% mathematically seamless infinite loop (0-frame reset or discontinuity)
class Premium3dSplashAnimation extends StatefulWidget {
  const Premium3dSplashAnimation({
    super.key,
    this.size = 175.0,
    this.loopDuration = const Duration(milliseconds: 4200),
    this.fadeInDuration = const Duration(milliseconds: 800),
    this.showBrandText = true,
    this.onCycleComplete,
    this.enableContinuousLoop = true,
  });

  /// Base dimension (width and height) of the 3D hero logo object.
  final double size;

  /// Duration for one complete seamless cinematic cycle.
  final Duration loopDuration;

  /// Duration of initial entrance materialize fade-in.
  final Duration fadeInDuration;

  /// Whether to display the understated brand wordmark and loading indicator.
  final bool showBrandText;

  /// Optional hook called at the apex of each completed loop cycle.
  final VoidCallback? onCycleComplete;

  /// Whether to loop continuously.
  final bool enableContinuousLoop;

  @override
  State<Premium3dSplashAnimation> createState() =>
      _Premium3dSplashAnimationState();
}

class _Premium3dSplashAnimationState extends State<Premium3dSplashAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _loopController;
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    )..forward();

    _loopController = AnimationController(
      vsync: this,
      duration: widget.loopDuration,
    );

    _loopController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCycleComplete?.call();
        if (widget.enableContinuousLoop) {
          _loopController.forward(from: 0.0);
        }
      }
    });

    _loopController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_loopController, _revealController]),
      builder: (context, _) {
        final t = _loopController.value;
        final reveal = CurvedAnimation(
          parent: _revealController,
          curve: Curves.easeOutCubic,
        ).value;

        return _buildCinematicExperience(context, t, reveal);
      },
    );
  }

  Widget _buildCinematicExperience(
    BuildContext context,
    double t,
    double reveal,
  ) {
    // ── Continuous Trigonometric Phase Angles (Guarantees Seamless Loop) ──
    final twoPiT = 2.0 * math.pi * t;

    // 1. Organic 3D Hover & Float
    // Peak elevation at t = 0.28 (-13.0px), descent trough at t = 0.78 (+10.0px)
    final floatY = -11.5 * math.sin(twoPiT);

    // 2. Controlled 3D Perspective Angles (Radians)
    // Subtle, believable pitch and yaw with a light roll
    final tiltX = 0.052 * math.sin(twoPiT + 0.35); // ±3.0 deg pitch
    final tiltY = 0.075 * math.cos(twoPiT); // ±4.3 deg yaw
    final tiltZ = 0.022 * math.sin(twoPiT - 0.45); // ±1.2 deg roll

    // 3. Heartbeat / Breathing Scale
    final breatheScale = 0.982 + 0.026 * ((1.0 - math.cos(twoPiT)) * 0.5);
    final totalScale = (0.95 + (0.05 * reveal)) * breatheScale;

    // 4. Ground Shadow Kinematics
    // Elevation normalized: 1.0 at highest point, -1.0 at lowest point
    final elevation = (-floatY / 11.5);
    final shadowScaleX = 1.0 + (0.15 * elevation);
    final shadowScaleY = 1.0 + (0.09 * elevation);
    final contactOpacity = (0.34 - (0.08 * elevation)).clamp(0.15, 0.45) * reveal;
    final ambientOpacity = (0.22 - (0.06 * elevation)).clamp(0.08, 0.30) * reveal;

    // 5. Ambient Emerald Stage Aura
    final auraPulse = 0.86 + 0.14 * ((1.0 - math.cos(twoPiT)) * 0.5);

    // 6. Specular Shimmer Sweep across 3D Facets
    // Windowed between t = 0.22 and t = 0.68
    const shimmerStart = 0.22;
    const shimmerEnd = 0.68;
    double shimmerSweep = 0.0;
    double shimmerAlpha = 0.0;

    if (t >= shimmerStart && t <= shimmerEnd) {
      final shimmerLocal = (t - shimmerStart) / (shimmerEnd - shimmerStart);
      shimmerSweep = -1.25 + (shimmerLocal * 3.5);
      shimmerAlpha = math.sin(shimmerLocal * math.pi);
    }

    // 7. Micro-Spark Glint 1 (Upper Right Arrow Crest)
    const g1Start = 0.34;
    const g1End = 0.48;
    double g1Scale = 0.0;
    double g1Rot = 0.0;

    if (t >= g1Start && t <= g1End) {
      final g1Local = (t - g1Start) / (g1End - g1Start);
      g1Scale = math.sin(g1Local * math.pi);
      g1Rot = g1Local * (math.pi / 2.8);
    }

    // 8. Micro-Spark Glint 2 (Lower Left Node Crossing)
    const g2Start = 0.50;
    const g2End = 0.64;
    double g2Scale = 0.0;
    double g2Rot = 0.0;

    if (t >= g2Start && t <= g2End) {
      final g2Local = (t - g2Start) / (g2End - g2Start);
      g2Scale = math.sin(g2Local * math.pi);
      g2Rot = -g2Local * (math.pi / 3.2);
    }

    // 9. Orbital Randomization Ring Rotation & Bead Flow
    final orbitAngle = twoPiT; // Completes 1 full revolution per loop cycle
    final orbitAlpha = (0.40 + 0.20 * math.sin(twoPiT)).clamp(0.20, 0.65) * reveal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = math.min(widget.size, constraints.maxWidth * 0.50);

        return Stack(
          alignment: Alignment.center,
          children: [
            // ── Stage Background: Warm Sand Gradient ──
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.15),
                    radius: 1.25,
                    colors: [
                      Color(0xFFFAF7F1), // Pure warm ivory glow center
                      Color(0xFFF3EBE0), // Velvety warm sand core
                      Color(0xFFE4D7C3), // Elegant beige perimeter depth
                    ],
                    stops: [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),

            // ── Soft Moving Light Haze / Radial Aura ──
            Transform.scale(
              scale: auraPulse * reveal,
              child: Container(
                width: logoSize * 2.5,
                height: logoSize * 2.5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x2E34D399), // Translucent mint/emerald bloom
                      Color(0x141B4332), // Deep forest mist
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),

            // ── Subtle Orbital Randomization Energy Ring ──
            Opacity(
              opacity: orbitAlpha,
              child: SizedBox(
                width: logoSize * 1.65,
                height: logoSize * 1.65,
                child: CustomPaint(
                  painter: _OrbitalRingPainter(
                    angle: orbitAngle,
                    color: const Color(0xFF2E6B4E),
                  ),
                ),
              ),
            ),

            // ── Ground Plane: Multi-Layer Realistic 3D Cast Shadow ──
            Positioned(
              top: (constraints.maxHeight / 2.0) + (logoSize * 0.40),
              child: Transform.scale(
                scaleX: shadowScaleX,
                scaleY: shadowScaleY,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer A: Wide atmospheric ambient diffusion
                    Opacity(
                      opacity: ambientOpacity,
                      child: Container(
                        width: logoSize * 0.95,
                        height: logoSize * 0.28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x35142B20),
                              blurRadius: 52.0,
                              spreadRadius: 8.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Layer B: Direct cast floor contact shadow
                    Opacity(
                      opacity: contactOpacity,
                      child: Container(
                        width: logoSize * 0.72,
                        height: logoSize * 0.18,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x5514231C),
                              blurRadius: 22.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero 3D Logo Object with Perspective & Shimmer ──
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014) // True 3D depth perspective
                ..translateByDouble(0.0, floatY, 0.0, 1.0)
                ..rotateX(tiltX)
                ..rotateY(tiltY)
                ..rotateZ(tiltZ)
                ..scaleByDouble(totalScale, totalScale, 1.0, 1.0),
              child: Opacity(
                opacity: reveal.clamp(0.0, 1.0),
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Base 3D Glossy Green Shuffle Symbol
                      Image.asset(
                        'assets/images/app_logo_transparent.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),

                      // Specular Reflection / Glass Light Sweep Pass
                      if (shimmerAlpha > 0.01)
                        Positioned.fill(
                          child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(
                                  shimmerSweep - 0.75,
                                  shimmerSweep - 0.75,
                                ),
                                end: Alignment(
                                  shimmerSweep + 0.75,
                                  shimmerSweep + 0.75,
                                ),
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.20 * shimmerAlpha),
                                  Colors.white.withValues(alpha: 0.75 * shimmerAlpha),
                                  const Color(0xFFD4FDE7).withValues(
                                    alpha: 0.95 * shimmerAlpha,
                                  ),
                                  Colors.white.withValues(alpha: 0.75 * shimmerAlpha),
                                  Colors.white.withValues(alpha: 0.20 * shimmerAlpha),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [
                                  0.0,
                                  0.24,
                                  0.45,
                                  0.50,
                                  0.55,
                                  0.76,
                                  1.0,
                                ],
                              ).createShader(bounds);
                            },
                            child: Image.asset(
                              'assets/images/app_logo_transparent.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),

                      // Micro-Spark Glint 1 (Upper Right Crest)
                      if (g1Scale > 0.01)
                        Positioned(
                          right: logoSize * 0.15,
                          top: logoSize * 0.13,
                          child: _MicroSparkGlint(
                            scale: g1Scale,
                            rotation: g1Rot,
                            color: const Color(0xFFF0FFF4),
                            coreSize: 24.0,
                          ),
                        ),

                      // Micro-Spark Glint 2 (Lower Left Node Crossing)
                      if (g2Scale > 0.01)
                        Positioned(
                          left: logoSize * 0.17,
                          bottom: logoSize * 0.20,
                          child: _MicroSparkGlint(
                            scale: g2Scale,
                            rotation: g2Rot,
                            color: const Color(0xFFFFF9E6),
                            coreSize: 20.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Understated Brand Wordmark & Loading Indicator ──
            if (widget.showBrandText)
              Positioned(
                top: (constraints.maxHeight / 2.0) + (logoSize * 0.58),
                child: Opacity(
                  opacity: reveal.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Two-tone luxury typography
                      RichText(
                        text: const TextSpan(
                          text: 'Shuffle ',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF14231C), // Deep forest near-black
                          ),
                          children: [
                            TextSpan(
                              text: 'Master',
                              style: TextStyle(
                                color: Color(0xFF2E6B4E), // Signature emerald
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Refined loading whisper: three synchronized breathing micro-dots
                      _LoadingWhisperPill(phase: t),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// An ethereal, thin orbital ring representing randomized rotational motion.
class _OrbitalRingPainter extends CustomPainter {
  const _OrbitalRingPainter({
    required this.angle,
    required this.color,
  });

  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radiusX = size.width * 0.48;
    final radiusY = size.height * 0.36;

    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    // Subtle hairline track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(rect, trackPaint);

    // Flowing orbital arc segment
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.55),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.70, 1.0],
        transform: GradientRotation(angle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    canvas.drawOval(rect, arcPaint);

    // Flowing orbital bead
    final beadX = center.dx + radiusX * math.cos(angle);
    final beadY = center.dy + radiusY * math.sin(angle);
    final beadCenter = Offset(beadX, beadY);

    final beadGlow = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beadCenter, 4.0, beadGlow);

    final beadCore = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beadCenter, 1.6, beadCore);
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}

/// A delicate 4-pointed specular flare with soft radial glow and diamond rays.
class _MicroSparkGlint extends StatelessWidget {
  const _MicroSparkGlint({
    required this.scale,
    required this.rotation,
    required this.color,
    required this.coreSize,
  });

  final double scale;
  final double rotation;
  final Color color;
  final double coreSize;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: coreSize,
          height: coreSize,
          child: CustomPaint(
            painter: _GlintPainter(color: color),
          ),
        ),
      ),
    );
  }
}

class _GlintPainter extends CustomPainter {
  const _GlintPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width / 2.0;

    // Soft spherical center halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.88),
          color.withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.44, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, haloPaint);

    // 4-point sharp diamond rays
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final path = Path();
    final rayLength = radius * 0.95;
    final rayWidth = radius * 0.18;

    // Horizontal ray
    path.moveTo(center.dx - rayLength, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - rayWidth, center.dx, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - rayWidth, center.dx + rayLength, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + rayWidth, center.dx, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + rayWidth, center.dx - rayLength, center.dy);

    // Vertical ray
    path.moveTo(center.dx, center.dy - rayLength);
    path.quadraticBezierTo(center.dx - rayWidth, center.dy, center.dx, center.dy);
    path.quadraticBezierTo(center.dx - rayWidth, center.dy, center.dx, center.dy + rayLength);
    path.quadraticBezierTo(center.dx + rayWidth, center.dy, center.dx, center.dy);
    path.quadraticBezierTo(center.dx + rayWidth, center.dy, center.dx, center.dy - rayLength);

    canvas.drawPath(path, rayPaint);

    // Intense center core pip
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.18, corePaint);
  }

  @override
  bool shouldRepaint(covariant _GlintPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Three synchronized micro-dots indicating active, intelligent loading.
class _LoadingWhisperPill extends StatelessWidget {
  const _LoadingWhisperPill({required this.phase});

  final double phase; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        // Offset each dot's phase by 0.18
        final localPhase = (phase + (index * 0.16)) % 1.0;
        final sineVal = math.sin(localPhase * 2.0 * math.pi);
        final opacity = (0.35 + 0.55 * ((sineVal + 1.0) / 2.0)).clamp(0.20, 1.0);
        final scale = 0.85 + 0.30 * ((sineVal + 1.0) / 2.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.5),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 5.0,
                height: 5.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2E6B4E), // Emerald brand color
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
