import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/audio_haptic_service.dart';
import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'widgets/coin_3d_widget.dart';

/// Coin Toss Screen following Apple Human Interface Guidelines:
/// - iOS 3D Coin Stage Card with Level 1 warm peach gradient surface
/// - Tactile PressableScale (scale 0.97) for primary actions
/// - 44x44 pt touch targets for all interactive controls
/// - Clear statistics cards and Inset Grouped history
class CoinTossScreen extends ConsumerStatefulWidget {
  const CoinTossScreen({super.key});

  @override
  ConsumerState<CoinTossScreen> createState() => _CoinTossScreenState();
}

class _CoinTossScreenState extends ConsumerState<CoinTossScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isTossing = false;
  bool _hasResult = false;
  CoinTossEntry? _lastResult;

  final AudioHapticService _audioHapticService = const AudioHapticService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _animationController.addListener(() {
      final v = _animationController.value;
      final settings = ref.read(settingsProvider);

      if (v >= 0.15 && v < 0.17) {
        _audioHapticService.playLaunch(settings);
      } else if (v >= 0.40 && v < 0.42) {
        _audioHapticService.playSpinTick(settings);
      } else if (v >= 0.82 && v < 0.84) {
        _audioHapticService.playLanding(settings);
      } else if (v >= 0.92 && v < 0.94) {
        _audioHapticService.playResult(settings);
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isTossing = false;
            _hasResult = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startToss() async {
    if (_isTossing) return;

    final settings = ref.read(settingsProvider);
    _audioHapticService.playLaunch(settings);

    // Compute result before physics animation begins
    final newEntry = await ref.read(coinTossProvider.notifier).tossCoin();

    setState(() {
      _isTossing = true;
      _hasResult = false;
      _lastResult = newEntry;
    });

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final coinTossNotifier = ref.read(coinTossProvider.notifier);
    final history = ref.watch(coinTossProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final totalTosses = coinTossNotifier.totalTosses;
    final headsCount = coinTossNotifier.headsCount;
    final tailsCount = coinTossNotifier.tailsCount;
    final headsPct = coinTossNotifier.headsPercentage;
    final tailsPct = coinTossNotifier.tailsPercentage;

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Large Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coin Toss',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesignTokens.textStrong,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '3D physics simulation · CSPRNG unbiased 50/50',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Interactive Coin Card Stage
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFCE3D0), // Peach/Gold tint
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: PremiumDesignTokens.cardBorder),
                    boxShadow: PremiumDesignTokens.cardShadow,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // Eyebrow Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: PremiumDesignTokens.innerBorder,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F1B4332),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 13, color: Color(0xFFD69A2D)),
                            SizedBox(width: 5),
                            Text(
                              'FAIR 50/50 DECISION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: PremiumDesignTokens.forestDark,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3D Coin Widget
                      Coin3DWidget(
                        animationController: _animationController,
                        isHeadsResult: _lastResult?.isHeads ?? true,
                        isAnimating: _isTossing,
                        hasResult: _hasResult,
                      ),

                      const SizedBox(height: 16),

                      // Result Status / Reveal
                      if (!_isTossing && !_hasResult)
                        const Text(
                          'Tap Toss to flip',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: PremiumDesignTokens.textStrong,
                          ),
                        )
                      else if (_isTossing)
                        const Text(
                          'Flipping in 3D...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: PremiumDesignTokens.forestDark,
                          ),
                        )
                      else if (_hasResult && _lastResult != null)
                        Column(
                          children: [
                            Text(
                              _lastResult!.isHeads ? 'HEADS' : 'TAILS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: _lastResult!.isHeads
                                    ? const Color(0xFFD69A2D)
                                    : PremiumDesignTokens.forestDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: PremiumDesignTokens.innerBorder,
                                ),
                              ),
                              child: const Text(
                                'Decided by Unbiased CSPRNG',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: PremiumDesignTokens.forestDark,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 22),

                      // Toss Button (Tactile scale, 44+ pt height)
                      PressableScale(
                        onTap: _isTossing ? null : _startToss,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: PremiumDesignTokens.gradPrimary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x331B4332),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasResult
                                    ? Icons.refresh_rounded
                                    : Icons.monetization_on_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isTossing
                                    ? 'FLIPPING...'
                                    : (_hasResult
                                        ? 'TOSS AGAIN'
                                        : 'TOSS COIN'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Statistics Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 20, 10),
                child: Text(
                  'STATISTICS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // Statistics Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _IOSStatCard(
                        label: 'Total',
                        value: '$totalTosses',
                        icon: Icons.bar_chart_rounded,
                        accentColor: PremiumDesignTokens.forestDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IOSStatCard(
                        label: 'Heads',
                        value: '$headsCount (${headsPct.toStringAsFixed(0)}%)',
                        icon: Icons.monetization_on_rounded,
                        accentColor: const Color(0xFFD69A2D),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IOSStatCard(
                        label: 'Tails',
                        value: '$tailsCount (${tailsPct.toStringAsFixed(0)}%)',
                        icon: Icons.shield_rounded,
                        accentColor: const Color(0xFF456B52),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Today's Tosses Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RECENT TOSSES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: PremiumDesignTokens.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (history.isNotEmpty)
                      GestureDetector(
                        onTap: () => _confirmClearHistory(context),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          height: 36,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PremiumDesignTokens.forestDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // History List
            if (history.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No toss history recorded today',
                      style: TextStyle(
                        fontSize: 14,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: history.take(15).length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final timeFormat = DateFormat('h:mm a');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: PremiumDesignTokens.cardBorder),
                          boxShadow: PremiumDesignTokens.cardShadow,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: entry.isHeads
                                    ? const Color(0xFFFDF7E7)
                                    : const Color(0xFFEAF1E9),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: Icon(
                                  entry.isHeads
                                      ? Icons.monetization_on_rounded
                                      : Icons.shield_rounded,
                                  size: 18,
                                  color: entry.isHeads
                                      ? const Color(0xFFD69A2D)
                                      : PremiumDesignTokens.forestDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.resultText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: entry.isHeads
                                          ? const Color(0xFFCA8A04)
                                          : PremiumDesignTokens.forestDark,
                                    ),
                                  ),
                                  Text(
                                    timeFormat.format(entry.tossedAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: PremiumDesignTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(coinTossProvider.notifier)
                                    .deleteEntry(entry.id);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const SizedBox(
                                width: 44,
                                height: 44,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: PremiumDesignTokens.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom Nav Clearance
            SliverPadding(
              padding: EdgeInsets.only(bottom: 110 + bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: PremiumDesignTokens.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Clear Toss History?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will reset your recorded coin tosses and percentages.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                  const Divider(height: 24),
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(coinTossProvider.notifier).clearHistory();
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Clear History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PressableScale(
              onTap: () => Navigator.pop(sheetContext),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: PremiumDesignTokens.cardShadow,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IOSStatCard extends StatelessWidget {
  const _IOSStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumDesignTokens.cardBorder),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: PremiumDesignTokens.textStrong,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: PremiumDesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
