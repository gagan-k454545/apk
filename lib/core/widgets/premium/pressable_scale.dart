import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium, tactile touch-feedback widget following Emil Kowalski's
/// motion philosophy:
/// - Tiny, crisp scale-down (to 0.97) on press
/// - Rapid response (120ms ease-out on press, 160ms on release)
/// - Subtly enhances perceived performance
/// - Respects reduced motion settings
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.targetScale = 0.97,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double targetScale;
  final bool enableHaptics;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 160),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.targetScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0), // Strong ease-out
        reverseCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _controller.forward();
    }
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          if (reduceMotion) {
            return widget.child;
          }
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
