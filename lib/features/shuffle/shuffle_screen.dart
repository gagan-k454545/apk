import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class ShuffleScreen extends ConsumerStatefulWidget {
  const ShuffleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<ShuffleScreen> createState() => _ShuffleScreenState();
}

class _ShuffleScreenState extends ConsumerState<ShuffleScreen>
    with TickerProviderStateMixin {
  late AnimationController _shuffleController;
  bool _isShuffling = false;
  bool _showResult = false;
  List<String> _result = [];
  String _groupName = '';

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loadGroup();
  }

  void _loadGroup() {
    final groups = ref.read(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: ''),
    );
    _groupName = group.name;
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }

  void _startShuffle() {
    final groups = ref.read(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: ''),
    );

    if (group.memberCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least 2 names to shuffle'),
        ),
      );
      return;
    }

    setState(() {
      _isShuffling = true;
      _showResult = false;
    });

    _shuffleController.forward(from: 0).then((_) {
      if (!mounted) return;
      final result = ref.read(shuffleServiceProvider).shuffle(group);
      ref.read(settingsProvider.notifier).incrementShuffles();
      ref.read(historyProvider.notifier).addEntry(
            HistoryEntry(
              groupId: group.id,
              groupName: group.name,
              result: result.shuffledOrder,
            ),
          );

      setState(() {
        _result = result.shuffledOrder;
        _isShuffling = false;
        _showResult = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = ref.watch(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: 'Unknown'),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(_groupName.isNotEmpty ? _groupName : 'Shuffle'),
            actions: [
              if (_showResult)
                IconButton(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                ),
              if (_showResult)
                IconButton(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Copy',
                ),
            ],
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  if (!_showResult) _buildShuffleAnimation(theme, group),
                  if (_showResult) ..._buildResultList(theme),
                  const Spacer(),
                  _buildBottomActions(theme, group),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShuffleAnimation(ThemeData theme, Group group) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shuffleController,
          builder: (context, child) {
            final value = _shuffleController.value;
            final rotation = value * 6 * pi;
            final scale = 1.0 + sin(value * 4 * pi) * 0.1;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(rotation)
                // ignore: deprecated_member_use
                ..scale(scale, scale, 1.0),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: _isShuffling ? 10 : 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shuffle,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          _isShuffling ? 'Shuffling...' : 'Ready to Shuffle',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${group.memberCount} ${group.memberCount == 1 ? 'name' : 'names'} in ${group.name}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_isShuffling) ...[
          const SizedBox(height: 24),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  List<Widget> _buildResultList(ThemeData theme) {
    final medals = ['🥇', '🥈', '🥉'];
    return [
      Text(
        'Result',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ).animate().fadeIn(),
      const SizedBox(height: 8),
      Text(
        'Random order generated',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ).animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 24),
      ...List.generate(_result.length, (index) {
        final name = _result[index];
        final medal = index < 3 ? medals[index] : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 24))
                : CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                fontSize: index < 3 ? 18 : 16,
              ),
            ),
            subtitle: index < 3 ? Text('Position ${index + 1}') : null,
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
            .slideX(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: 300 + (index * 100)),
            );
      }),
    ];
  }

  Widget _buildBottomActions(ThemeData theme, Group group) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isShuffling ? null : _startShuffle,
            icon: Icon(_showResult ? Icons.refresh : Icons.shuffle),
            label: Text(_showResult ? 'Shuffle Again' : 'Start Shuffle'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ).animate().fadeIn(delay: _showResult ? 500.ms : Duration.zero),
        if (_showResult) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ],
    );
  }

  String get _resultAsText {
    return _result
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _resultAsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied to clipboard')),
    );
  }

  void _shareResult() {
    Share.share(
      '🎲 Shuffle Master Result - $_groupName\n\n$_resultAsText',
    );
  }
}
