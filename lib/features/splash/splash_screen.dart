import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/premium_3d_splash_logo.dart';

/// The luxury startup splash screen for Shuffle Master.
///
/// Clean, minimalist, and focused solely on the cinematic 3D logo animation.
/// Seamlessly loops without jumps, and transitions gracefully to `/home`.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.displayDuration = const Duration(milliseconds: 3800),
    this.onProceed,
  });

  /// Whether to automatically transition to `/home` after [displayDuration].
  final bool autoNavigate;

  /// Duration before transitioning to the home screen.
  final Duration displayDuration;

  /// Optional custom callback invoked upon exit instead of [context.go('/home')].
  final VoidCallback? onProceed;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exitController;
  Timer? _timer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.autoNavigate) {
      _timer = Timer(widget.displayDuration, _proceedToHome);
    }
  }

  void _proceedToHome() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    // Smooth cinematic exit fade
    _exitController.forward().then((_) {
      if (mounted) {
        if (widget.onProceed != null) {
          widget.onProceed!();
        } else {
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _proceedToHome, // Allow quick skip if user taps
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EBE0),
        body: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            final exitProgress = _exitController.value;
            final opacity = (1.0 - exitProgress).clamp(0.0, 1.0);
            final scale = 1.0 + (0.04 * exitProgress);

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: const Center(
            child: Premium3dSplashAnimation(
              size: 190.0,
            ),
          ),
        ),
      ),
    );
  }
}
