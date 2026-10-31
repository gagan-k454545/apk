import 'package:flutter/material.dart';
import '../../theme/premium_design_tokens.dart';
import 'pressable_scale.dart';

/// The tactile center floating shuffle button.
/// Elevated slightly above the bottom navigation bar, with:
/// - Dark forest green gradient
/// - White criss-cross shuffle icon
/// - Ambient glow shadow
/// - Tactile scale feedback
class FloatingCenterAction extends StatelessWidget {
  const FloatingCenterAction({
    super.key,
    required this.onTap,
    this.size = 56.0,
    this.iconSize = 28.0,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      targetScale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2C553C),
              Color(0xFF1E3A2B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF456B52).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D1E3A2B),
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.shuffle_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

/// Custom Premium Bottom Navigation Bar matching the reference screenshots.
/// Features:
/// - Ivory / frosted surface with subtle top border and soft shadow
/// - Selected items have an active forest green pill container
/// - Inactive items have clean slate typography and icons
/// - Center cutout slot for the elevated `FloatingCenterAction`
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1A231C)
        : const Color(0xFFFCFAF6);
    final borderColor = isDark
        ? const Color(0xFF2D3C2F)
        : const Color(0xFFEDE6DA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. Home
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_rounded,
                  unselectedIcon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  isDark: isDark,
                ),
              ),

              // 2. Groups
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.groups_rounded,
                  unselectedIcon: Icons.group_outlined,
                  label: 'Groups',
                  isSelected: currentIndex == 1,
                  isDark: isDark,
                ),
              ),

              // 3. Center Elevated Action Button
              SizedBox(
                width: 68,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: FloatingCenterAction(onTap: onCenterTap),
                  ),
                ),
              ),

              // 4. History
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.history_rounded,
                  unselectedIcon: Icons.history_outlined,
                  label: 'History',
                  isSelected: currentIndex == 2,
                  isDark: isDark,
                ),
              ),

              // 5. Settings
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.settings_rounded,
                  unselectedIcon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: currentIndex == 3,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    const activeColor = PremiumDesignTokens.mossDark;
    final inactiveColor = isDark
        ? const Color(0xFF8A9C8E)
        : const Color(0xFF8E9B91);

    return PressableScale(
      onTap: () => onTap(index),
      targetScale: 0.94,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? const Color(0xFF2E4634)
                      : PremiumDesignTokens.mossDark)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? icon : unselectedIcon,
              size: 22,
              color: isSelected ? Colors.white : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? const Color(0xFFD3E5D6) : activeColor)
                  : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
