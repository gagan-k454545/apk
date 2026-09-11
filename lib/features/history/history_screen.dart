import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _selectedTab = 0; // 0 = Name Shuffles, 1 = Coin Tosses

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ref.watch(historyProvider);
    final coinTossHistory = ref.watch(coinTossProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('History'),
            actions: [
              if ((_selectedTab == 0 && history.isNotEmpty) ||
                  (_selectedTab == 1 && coinTossHistory.isNotEmpty))
                IconButton(
                  onPressed: () {
                    if (_selectedTab == 0) {
                      _confirmClearShuffleHistory(context, ref);
                    } else {
                      _confirmClearCoinHistory(context, ref);
                    }
                  },
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear History',
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Name Shuffles'),
                    icon: Icon(Icons.shuffle),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Coin Tosses'),
                    icon: Icon(Icons.monetization_on_outlined),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedTab = set.first;
                  });
                },
              ),
            ),
          ),
          if (_selectedTab == 0)
            ..._buildShuffleHistorySlivers(context, theme, history)
          else
            ..._buildCoinTossHistorySlivers(context, theme, coinTossHistory),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  List<Widget> _buildShuffleHistorySlivers(
      BuildContext context, ThemeData theme, List<HistoryEntry> history) {
    if (history.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  Text(
                    'No Shuffle History',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your name shuffle results will appear here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final groupedHistory = _groupByDate(history);
    final slivers = <Widget>[];

    for (final entry in groupedHistory.entries) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                ...entry.value.map((historyEntry) {
                  return _HistoryCard(
                    entry: historyEntry,
                    onDelete: () {
                      ref
                          .read(historyProvider.notifier)
                          .deleteEntry(historyEntry.id);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  List<Widget> _buildCoinTossHistorySlivers(
      BuildContext context, ThemeData theme, List<CoinTossEntry> coinTosses) {
    if (coinTosses.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  Text(
                    'No Coin Toss History',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your coin toss decisions will appear here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final timeFormat = DateFormat('h:mm a · MMM d');

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList.builder(
          itemCount: coinTosses.length,
          itemBuilder: (context, index) {
            final entry = coinTosses[index];
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
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () {
                    ref.read(coinTossProvider.notifier).deleteEntry(entry.id);
                  },
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: index * 30));
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

  void _confirmClearShuffleHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_sweep_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Clear Shuffle History?'),
        content: const Text('This will permanently remove all name shuffle history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCoinHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_sweep_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Clear Coin History?'),
        content: const Text('This will permanently remove all coin toss history.'),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shuffle,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.groupName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${entry.count} ${entry.count == 1 ? 'name' : 'names'} · ${timeFormat.format(entry.shuffledAt)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.result
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => '${e.key + 1}. ${e.value}')
                      .join('\n'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (entry.result.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${entry.result.length - 3} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
