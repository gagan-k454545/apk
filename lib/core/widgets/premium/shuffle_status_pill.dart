import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A refined status badge / pill indicating successful shuffle completion.
/// Features a calm sage green tint, check icon, and soft entrance motion.
class ShuffleStatusPill extends StatefulWidget {
  const ShuffleStatusPill({
    super.key,
    this.text = 'Shuffle Complete!',
    this.icon = Icons.check_circle_rounded,
    this.animateOnMount = true,
  });

  final String text;
  final IconData icon;
  final bool animateOnMount;

  @override
  State<ShuffleStatusPill> createState() => _ShuffleStatusPillState();
}

class _ShuffleStatusPillState extends State<ShuffleStatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.animateOnMount) {
      _animController.forward();
    } else {
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final pillContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.sageBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08254835),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 17,
            color: AppColors.sageOnContainer,
          ),
          const SizedBox(width: 7),
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.sageOnContainer,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (reduceMotion) {
      return pillContent;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: pillContent,
      ),
    );
  }
}
