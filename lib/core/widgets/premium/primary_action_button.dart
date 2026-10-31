import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'pressable_scale.dart';

enum ActionButtonVariant {
  primary,
  secondary,
}

/// A tactile, rounded action button with crisp press feedback,
/// state morphing (idle -> loading -> success), and premium depth.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = ActionButtonVariant.primary,
    this.isLoading = false,
    this.isSuccess = false,
    this.successLabel = 'Saved!',
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final ActionButtonVariant variant;
  final bool isLoading;
  final bool isSuccess;
  final String successLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPrimary = variant == ActionButtonVariant.primary;

    Color backgroundColor;
    if (isSuccess) {
      backgroundColor = const Color(0xFF235C38);
    } else if (isPrimary) {
      backgroundColor = isDark ? const Color(0xFF294D36) : AppColors.mossDark;
    } else {
      backgroundColor = isDark ? const Color(0xFF202A22) : AppColors.creamCard;
    }

    final foregroundColor = (isPrimary || isSuccess)
        ? Colors.white
        : (isDark ? const Color(0xFFE5EDE6) : AppColors.textHeadline);

    final borderColor = (isPrimary || isSuccess)
        ? Colors.transparent
        : (isDark ? const Color(0xFF334336) : AppColors.hairline);

    return PressableScale(
      onTap: (isLoading || isSuccess) ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: (isPrimary || isSuccess) ? 0 : 1.2,
          ),
          boxShadow: (isPrimary || isSuccess)
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.mossDark)
                        .withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  )
                : isSuccess
                    ? Row(
                        key: const ValueKey('success'),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            successLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: ValueKey('normal_$label'),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 19,
                            color: foregroundColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: foregroundColor,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
