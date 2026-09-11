import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/services/audio_haptic_service.dart';
import 'widgets/coin_3d_widget.dart';

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

      // Trigger audio & haptics at specific phase milestones
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
    if (_isTossing) return; // Prevent double taps

    final settings = ref.read(settingsProvider);
    _audioHapticService.playLaunch(settings);

    // Requirement 4: Predetermine result before animation starts
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
    final theme = Theme.of(context);
    final coinTossNotifier = ref.read(coinTossProvider.notifier);
    final history = ref.watch(coinTossProvider);

    final totalTosses = coinTossNotifier.totalTosses;
    final headsCount = coinTossNotifier.headsCount;
    final tailsCount = coinTossNotifier.tailsCount;
    final headsPct = coinTossNotifier.headsPercentage;
    final tailsPct = coinTossNotifier.tailsPercentage;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Screen Header
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Coin Toss'),
                Text(
                  'Let chance make the decision.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Main Interactive Coin Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 3D Coin Widget
                  Coin3DWidget(
                    animationController: _animationController,
                    isHeadsResult: _lastResult?.isHeads ?? true,
                    isAnimating: _isTossing,
                    hasResult: _hasResult,
                  ),

                  const SizedBox(height: 16),

                  // Status / Result Reveal Text
                  if (!_isTossing && !_hasResult)
                    Text(
                      'Ready to toss?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn()
                  else if (_isTossing)
                    Text(
                      'Flipping coin...',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else if (_hasResult && _lastResult != null)
                    Column(
                      children: [
                        Text(
                          _lastResult!.isHeads ? 'HEADS' : 'TAILS',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: _lastResult!.isHeads
                                ? const Color(0xFFEAB308)
                                : theme.colorScheme.primary,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .scale(begin: const Offset(0.7, 0.7)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Decided by True Randomness',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                    ),

                  const SizedBox(height: 28),

                  // Toss Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isTossing ? null : _startToss,
                      icon: Icon(
                        _hasResult ? Icons.refresh_rounded : Icons.monetization_on_outlined,
                        size: 22,
                      ),
                      label: Text(
                        _isTossing
                            ? 'FLIPPING...'
                            : (_hasResult ? 'TOSS AGAIN' : 'TOSS COIN'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Statistics Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Toss Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Statistics Cards Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Total Tosses',
                          value: '$totalTosses',
                          icon: Icons.bar_chart_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Heads',
                          value: '$headsCount (${headsPct.toStringAsFixed(0)}%)',
                          icon: Icons.workspace_premium,
                          color: const Color(0xFFEAB308),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Tails',
                          value: '$tailsCount (${tailsPct.toStringAsFixed(0)}%)',
                          icon: Icons.stars_rounded,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Today's Tosses Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Tosses',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _confirmClearHistory(context),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),
          ),

          // History List
          if (history.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Tosses Yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap TOSS COIN above to make a decision.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final timeFormat = DateFormat('h:mm a');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: entry.isHeads
                              ? const Color(0xFFFEF9C3)
                              : theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          entry.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        entry.resultText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: entry.isHeads
                              ? const Color(0xFFCA8A04)
                              : theme.colorScheme.primary,
                        ),
                      ),
                      subtitle: Text(
                        timeFormat.format(entry.tossedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          ref
                              .read(coinTossProvider.notifier)
                              .deleteEntry(entry.id);
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: index * 40));
                },
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Coin History?'),
        content: const Text('This will clear all saved coin toss records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(coinTossProvider.notifier).clearHistory();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
