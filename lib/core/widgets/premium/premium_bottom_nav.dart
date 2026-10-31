import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/premium_design_tokens.dart';
import 'pressable_scale.dart';

/// The center tactile Floating Shuffle Button matching Section 5.8:
/// - 56x56 circle, gradPrimary, white Shuffle icon 26px
/// - Raised ~18px above the bar
/// - Outer halo ring (0 0 0 6px rgba(255,252,247,.95)) + shadowLg
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
    const haloColor = Color(0xF5FFFCF7); // rgba(255,252,247,.95)

    final fab = Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: PremiumDesignTokens.gradPrimary,
        boxShadow: [
          // Outer halo ring (0 0 0 6px rgba(255,252,247,.95))
          BoxShadow(
            color: haloColor,
            spreadRadius: 5,
          ),
          ...PremiumDesignTokens.shadowLg,
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

/// Floating Navigation Bar matching Section 5.8 & Requirement 4:
/// - Margin horizontal 12, bottom max(12, safe-area), height ~64, radius 28
/// - bg rgba(255,252,247,.94) (light translucent cream, never dark)
/// - borderGlass, shadowLg
/// - 6 items plus raised center FAB:
///   1. Home
///   2. Groups
///   3. Alerts (Bell with unread dot)
///   [Center FAB]
///   4. Coin Toss
///   5. History
///   6. Settings
/// - Active item = dark green pill (gradPrimary, white icon, 8x16, radius 18) with label in --green-800 bold
class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
    this.hasUnreadAlerts = true,
    this.onAlertsTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;
  final bool hasUnreadAlerts;
  final VoidCallback? onAlertsTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const bgColor = Color(0xF2FFFCF7); // rgba(255,252,247,.95) light translucent cream

    return Container(
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        math.max(10.0, bottomInset),
      ),
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: PremiumDesignTokens.borderGlass,
        ),
        boxShadow: PremiumDesignTokens.shadowLg,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 6 Navigation Tab Items
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

              // 3. Alerts (Bell with optional orange dot)
              Expanded(
                child: PressableScale(
                  onTap: () {
                    if (onAlertsTap != null) {
                      onAlertsTap!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All caught up! No new notifications.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  targetScale: 0.94,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: PremiumDesignTokens.textMuted,
                      ),
                      if (hasUnreadAlerts)
                        Positioned(
                          top: 18,
                          right: 14,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: PremiumDesignTokens.orange500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Spacer gap for Center Raised FAB
              const SizedBox(width: 58),

              // 4. Coin Toss (index 2)
              Expanded(
                child: _buildTabItem(
                  index: 2,
                  icon: Icons.monetization_on_rounded,
                  unselectedIcon: Icons.monetization_on_outlined,
                  label: 'Coin Toss',
                  isSelected: currentIndex == 2,
                ),
              ),

              // 5. History (index 3)
              Expanded(
                child: _buildTabItem(
                  index: 3,
                  icon: Icons.history_rounded,
                  unselectedIcon: Icons.history_outlined,
                  label: 'History',
                  isSelected: currentIndex == 3,
                ),
              ),

              // 6. Settings (index 4)
              Expanded(
                child: _buildTabItem(
                  index: 4,
                  icon: Icons.settings_rounded,
                  unselectedIcon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: currentIndex == 4,
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
    const inactiveColor = PremiumDesignTokens.textMuted;

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
              horizontal: isSelected ? 14 : 6,
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
