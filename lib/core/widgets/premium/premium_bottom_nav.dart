import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/premium_design_tokens.dart';
import 'pressable_scale.dart';

/// Center tactile Floating Shuffle Button matching Section 5.8:
/// - 56x56 circle, gradPrimary, white Shuffle icon 26px
/// - Raised ~18px above the bar
/// - Outer halo ring (0 0 0 6px rgba(255,255,255,.96)) + shadow
/// - Subtle idle pulse (scale 1.0 to 1.04, 2.4s) with reduced motion fallback
/// - Tactile scale (.92) on press
class FloatingCenterAction extends StatefulWidget {
  const FloatingCenterAction({
    super.key,
    required this.onTap,
    this.size = 56.0,
    this.iconSize = 26.0,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  State<FloatingCenterAction> createState() => _FloatingCenterActionState();
}

class _FloatingCenterActionState extends State<FloatingCenterAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    const haloColor = Color(0xF5FFFFFF); // rgba(255,255,255,0.96)

    final fab = Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: PremiumDesignTokens.gradPrimary,
        boxShadow: [
          // Outer halo ring (0 0 0 6px rgba(255,255,255,.96))
          BoxShadow(
            color: haloColor,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Color(0x381B4332), // 0 14px 34px rgba(27,67,50,0.22)
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.shuffle_rounded,
          color: Colors.white,
          size: widget.iconSize,
        ),
      ),
    );

    return PressableScale(
      onTap: widget.onTap,
      targetScale: 0.92,
      child: reduceMotion
          ? fab
          : AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.04);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: fab,
            ),
    );
  }
}

/// Floating Navigation Bar matching Section 5.8 & Level 1 Surface Hierarchy:
/// - Near-opaque: background rgba(255,255,255,0.96)
/// - Border: 1px rgba(27,67,50,0.10)
/// - Shadow: 0 -2px 0 rgba(255,255,255,0.8), 0 14px 34px rgba(27,67,50,0.20)
/// - Balanced layout avoiding label collision around center FAB
class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        math.max(10.0, bottomInset),
      ),
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Solid White Floating Pill (Level 1 surface)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // Solid #FFFFFF (no translucency, no blur)
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0x241B4332), // 1.5px solid rgba(27,67,50,0.14)
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCCFFFFFF), // Specular highlight
                    offset: Offset(0, -2),
                  ),
                  BoxShadow(
                    color: Color(0x401B4332), // 0 16px 36px rgba(27,67,50,0.25)
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
            ),
          ),
          // Navigation Tab Items with Equal Clearance Around Center FAB (Home, Groups | FAB | Coin Toss, History)
          Row(
            children: [
              // 1. Home (index 0)
              Expanded(
                child: _buildTabItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                ),
              ),

              // 2. Groups (index 1)
              Expanded(
                child: _buildTabItem(
                  index: 1,
                  icon: Icons.groups_rounded,
                  unselectedIcon: Icons.group_outlined,
                  label: 'Groups',
                  isSelected: currentIndex == 1,
                ),
              ),

              // Equal Center Clearance for Raised FAB
              const SizedBox(width: 68),

              // 3. Coin Toss (index 2)
              Expanded(
                child: _buildTabItem(
                  index: 2,
                  icon: Icons.monetization_on_rounded,
                  unselectedIcon: Icons.monetization_on_outlined,
                  label: 'Coin Toss',
                  isSelected: currentIndex == 2,
                ),
              ),

              // 4. History (index 3)
              Expanded(
                child: _buildTabItem(
                  index: 3,
                  icon: Icons.history_rounded,
                  unselectedIcon: Icons.history_outlined,
                  label: 'History',
                  isSelected: currentIndex == 3,
                ),
              ),
            ],
          ),

          // Center Raised FAB (-18px above the bar)
          Positioned(
            top: -18,
            child: FloatingCenterAction(onTap: onCenterTap),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
    required bool isSelected,
  }) {
    const inactiveColor = Color(0xFF6B7C72); // Inactive items: icon + label both in #6B7C72

    return PressableScale(
      onTap: () => onTap(index),
      targetScale: 0.94,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active Dark Green Capsule Pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12 : 4,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? PremiumDesignTokens.gradPrimary
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? icon : unselectedIcon,
              size: 20,
              color: isSelected ? Colors.white : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? PremiumDesignTokens.green800
                  : inactiveColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
