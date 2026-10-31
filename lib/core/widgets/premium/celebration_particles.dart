import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Celebratory particle burst for rare, delightful moments (Shuffle completion).
/// Strictly adheres to Emil Kowalski's "Delight Budget" philosophy:
/// - Light, soft, luxurious motion (never garish)
/// - Uses ease-out deceleration with natural settling
/// - Fades away smoothly within 850ms
/// - Bypassed entirely when reduced-motion is requested
class CelebrationParticles extends StatefulWidget {
  const CelebrationParticles({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  final bool isPlaying;
  final Widget child;

  @override
  State<CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<CelebrationParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ParticleData> _particles;
  final Random _rnd = Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _particles = List.generate(14, (i) {
      final angle = (i / 14) * 2 * pi + (_rnd.nextDouble() * 0.3 - 0.15);
      final distance = 60.0 + _rnd.nextDouble() * 55.0;
      final size = 4.0 + _rnd.nextDouble() * 4.0;
      final isGold = i % 2 == 0;
      final isStar = i % 3 == 0;

      return _ParticleData(
        angle: angle,
        distance: distance,
        size: size,
        color: isGold
            ? (i % 4 == 0 ? AppColors.warmGold : const Color(0xFFE9C579))
            : (i % 3 == 0 ? AppColors.sageMedium : AppColors.peachAccent),
        isStar: isStar,
      );
    });

    if (widget.isPlaying) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(CelebrationParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.value == 0 || _controller.value == 1.0) {
              return const SizedBox.shrink();
            }

            final progress = _controller.value;
            // Strong ease-out expansion
            final curvedDistance =
                const Cubic(0.23, 1.0, 0.32, 1.0).transform(progress);
            final opacity = (1.0 - progress).clamp(0.0, 1.0);

            return SizedBox(
              width: 240,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: _particles.map((p) {
                  final dist = p.distance * curvedDistance;
                  final x = cos(p.angle) * dist;
                  // add soft gravity drop
                  final y = sin(p.angle) * dist * 0.75 + (progress * 18);

                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Opacity(
                      opacity: opacity,
                      child: p.isStar
                          ? Icon(
                              Icons.auto_awesome,
                              size: p.size * 2,
                              color: p.color,
                            )
                          : Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ParticleData {
  _ParticleData({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.isStar,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final bool isStar;
}
