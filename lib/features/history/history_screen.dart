import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// History Screen following Apple Human Interface Guidelines:
/// - iOS Segmented Control for switching Shuffles & Coin Tosses
/// - Date grouped sections ("Today", "Yesterday", "Earlier")
/// - Inset Grouped card architecture with 3-level surface hierarchy
/// - 44x44 pt touch targets for all interactive elements
/// - Tactile press feedback with subtle haptics
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _selectedTab = 0; // 0 = Name Shuffles, 1 = Coin Tosses

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final coinTossHistory = ref.watch(coinTossProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final bool hasItems = _selectedTab == 0
        ? history.isNotEmpty
        : coinTossHistory.isNotEmpty;

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Large Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'History',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedTab == 0
                                ? '${history.length} completed ${history.length == 1 ? 'shuffle' : 'shuffles'}'
                                : '${coinTossHistory.length} total coin ${coinTossHistory.length == 1 ? 'toss' : 'tosses'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: PremiumDesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasItems)
                      GestureDetector(
                        onTap: () {
                          if (_selectedTab == 0) {
                            _confirmClearShuffleHistory(context);
                          } else {
                            _confirmClearCoinHistory(context);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.delete_sweep_outlined,
                            size: 22,
                            color: PremiumDesignTokens.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // iOS Sliding Segmented Control
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                child: _IOSSegmentedControl(
                  selectedIndex: _selectedTab,
                  onChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),
              ),
            ),

            // Content Slivers
            if (_selectedTab == 0)
              ..._buildShuffleHistorySlivers(context, history)
            else
              ..._buildCoinTossHistorySlivers(context, coinTossHistory),

            // Bottom Nav Clearance
            SliverPadding(
              padding: EdgeInsets.only(bottom: 110 + bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildShuffleHistorySlivers(
      BuildContext context, List<HistoryEntry> history) {
    if (history.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: PremiumDesignTokens.cardBorder),
                      boxShadow: PremiumDesignTokens.cardShadow,
                    ),
                    child: const Icon(
                      Icons.shuffle_rounded,
                      size: 38,
                      color: PremiumDesignTokens.forestDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Shuffle History',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your randomized order results will be logged here for easy review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final grouped = _groupByDate(history);
    final slivers = <Widget>[];

    for (final entry in grouped.entries) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 20, 6),
            child: Text(
              entry.key.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PremiumDesignTokens.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final item = entry.value[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IOSShuffleHistoryCard(
                  entry: item,
                  onDelete: () {
                    HapticFeedback.lightImpact();
                    ref.read(historyProvider.notifier).deleteEntry(item.id);
                  },
                ),
              );
            },
          ),
        ),
      );
    }

    return slivers;
  }

  List<Widget> _buildCoinTossHistorySlivers(
      BuildContext context, List<CoinTossEntry> coinTosses) {
    if (coinTosses.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: PremiumDesignTokens.cardBorder),
                      boxShadow: PremiumDesignTokens.cardShadow,
                    ),
                    child: const Icon(
                      Icons.monetization_on_outlined,
                      size: 38,
                      color: Color(0xFFD69A2D),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Coin Toss History',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Decide instant 50/50 heads or tails flips. Results will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final int headsCount = coinTosses.where((e) => e.isHeads).length;
    final int tailsCount = coinTosses.length - headsCount;
    final double headsPercent =
        coinTosses.isNotEmpty ? (headsCount / coinTosses.length) * 100 : 0.0;

    return [
      // Quick Stats Banner
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PremiumDesignTokens.cardBorder),
              boxShadow: PremiumDesignTokens.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HEADS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCA8A04),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$headsCount (${headsPercent.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PremiumDesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PremiumDesignTokens.forestDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$tailsCount (${(100 - headsPercent).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PremiumDesignTokens.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Coin Toss List
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.builder(
          itemCount: coinTosses.length,
          itemBuilder: (context, index) {
            final entry = coinTosses[index];
            final timeFormat = DateFormat('h:mm a · MMM d');

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PremiumDesignTokens.cardBorder),
                  boxShadow: PremiumDesignTokens.cardShadow,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: entry.isHeads
                            ? const Color(0xFFFDF7E7)
                            : const Color(0xFFEAF1E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: entry.isHeads
                              ? const Color(0xFFE8CF96)
                              : const Color(0xFFD0E0CE),
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        entry.isHeads
                            ? Icons.monetization_on_rounded
                            : Icons.shield_rounded,
                        size: 22,
                        color: entry.isHeads
                            ? const Color(0xFFD69A2D)
                            : PremiumDesignTokens.forestDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.resultText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: entry.isHeads
                                  ? const Color(0xFFCA8A04)
                                  : PremiumDesignTokens.forestDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeFormat.format(entry.tossedAt),
                            style: const TextStyle(
                              fontSize: 12,
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
                            Icons.delete_outline,
                            size: 19,
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
    ];
  }

  Map<String, List<HistoryEntry>> _groupByDate(List<HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<HistoryEntry>>{};

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.shuffledAt.year,
        entry.shuffledAt.month,
        entry.shuffledAt.day,
      );

      String label;
      if (entryDate == today) {
        label = 'Today';
      } else if (entryDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, y').format(entry.shuffledAt);
      }

      grouped.putIfAbsent(label, () => []).add(entry);
    }

    return grouped;
  }

  void _confirmClearShuffleHistory(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
                    'Clear Shuffle History?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will permanently delete all recorded shuffle orders.',
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
                      ref.read(historyProvider.notifier).clearAll();
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Clear Shuffle History',
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

  void _confirmClearCoinHistory(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
                    'Clear Coin History?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will reset all coin toss records and counters.',
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
                        'Clear Coin History',
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

/// iOS Segmented Control with smooth sliding pill animation.
class _IOSSegmentedControl extends StatelessWidget {
  const _IOSSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0x1F1B4332), // subtle tint
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          // Animated sliding white pill
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: const Cubic(0.23, 1.0, 0.32, 1.0),
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A1B4332),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tap labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(0);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Name Shuffles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selectedIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == 0
                            ? PremiumDesignTokens.forestDark
                            : PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(1);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Coin Tosses',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selectedIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == 1
                            ? PremiumDesignTokens.forestDark
                            : PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IOSShuffleHistoryCard extends StatelessWidget {
  const _IOSShuffleHistoryCard({
    required this.entry,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final winner = entry.result.isNotEmpty ? entry.result.first : 'None';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFBF7F0),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PremiumDesignTokens.cardBorder),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1E9),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: PremiumDesignTokens.innerBorder),
                ),
                child: const Icon(
                  Icons.shuffle_rounded,
                  size: 19,
                  color: PremiumDesignTokens.forestDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PremiumDesignTokens.textStrong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.count} members · ${timeFormat.format(entry.shuffledAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // #1 Winner Pill Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EEDC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0x1F1B4332),
                width: 0.6,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 17,
                  color: Color(0xFFD69A2D),
                ),
                const SizedBox(width: 8),
                const Text(
                  '1st: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    winner,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PremiumDesignTokens.forestDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Subsequent members preview
          if (entry.result.length > 1) ...[
            Text(
              entry.result
                  .skip(1)
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map((e) => '${e.key + 2}. ${e.value}')
                  .join('   ·   '),
              style: const TextStyle(
                fontSize: 12,
                color: PremiumDesignTokens.textMuted,
              ),
            ),
            if (entry.result.length > 4) ...[
              const SizedBox(height: 4),
              Text(
                '+${entry.result.length - 4} more members',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PremiumDesignTokens.forestDark,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
