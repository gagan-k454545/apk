import 'package:flutter/material.dart';
import '../../../core/theme/premium_design_tokens.dart';
import '../../../core/widgets/premium/primary_action_button.dart';

/// Bottom docked action bar featuring side-by-side buttons:
/// - Shuffle Again (Secondary tactile action)
/// - Save Order (Primary prominent action with state morphing)
class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({
    super.key,
    required this.onShuffleAgain,
    required this.onSaveOrder,
    this.isShuffling = false,
    this.isSaved = false,
  });

  final VoidCallback? onShuffleAgain;
  final VoidCallback? onSaveOrder;
  final bool isShuffling;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : PremiumDesignTokens.background.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2C3930)
                : PremiumDesignTokens.hairline.withValues(alpha: 0.8),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Shuffle Again
          Expanded(
            child: PrimaryActionButton(
              label: isShuffling ? 'Shuffling...' : 'Shuffle Again',
              icon: Icons.refresh_rounded,
              variant: ActionButtonVariant.secondary,
              isLoading: isShuffling,
              onPressed: isShuffling ? null : onShuffleAgain,
            ),
          ),
          const SizedBox(width: 12),

          // Right: Save Order
          Expanded(
            child: PrimaryActionButton(
              label: 'Save Order',
              icon: Icons.check_circle_rounded,
              isSuccess: isSaved,
              successLabel: 'Order Saved!',
              onPressed: isShuffling ? null : onSaveOrder,
            ),
          ),
        ],
      ),
    );
  }
}
