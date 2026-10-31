import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';

/// A refined status badge / pill indicating successful shuffle completion.
/// Features a calm sage green confirmation style, check icon, and soft entrance motion.
class SuccessBadge extends StatefulWidget {
  const SuccessBadge({
    super.key,
    this.label = 'Shuffle Complete!',
    this.icon = Icons.check_circle_rounded,
    this.animateOnMount = true,
  });

  final String label;
  final IconData icon;
  final bool animateOnMount;

  @override
  State<SuccessBadge> createState() => _SuccessBadgeState();
}

class _SuccessBadgeState extends State<SuccessBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: PremiumDesignTokens.durationEntrance,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: PremiumDesignTokens.easeOutCubic,
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

    final badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PremiumDesignTokens.sageLight,
        borderRadius: BorderRadius.circular(PremiumDesignTokens.radiusPill),
        border: Border.all(
          color: PremiumDesignTokens.sageBorder,
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
            color: PremiumDesignTokens.sageText,
          ),
          const SizedBox(width: 7),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PremiumDesignTokens.sageText,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (reduceMotion) {
      return badgeContent;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: badgeContent,
      ),
    );
  }
}
