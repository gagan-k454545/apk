import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/services/audio_haptic_service.dart';

class ShuffleScreen extends ConsumerStatefulWidget {
  const ShuffleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<ShuffleScreen> createState() => _ShuffleScreenState();
}

class _ShuffleScreenState extends ConsumerState<ShuffleScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconSpinController;
  late AnimationController _cardShuffleController;

  bool _isShuffling = false;
  bool _showResult = false;
  List<String> _result = [];
  List<String> _visualShuffleList = [];
  String _groupName = '';

  Timer? _intermediateTimer;
  final AudioHapticService _audioHapticService = const AudioHapticService();
  final Random _visualRandom = Random();

  @override
  void initState() {
    super.initState();
    _iconSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _cardShuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _loadGroup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShuffle();
    });
  }

  void _loadGroup() {
    final groups = ref.read(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: ''),
    );
    _groupName = group.name;
    if (group.members.isNotEmpty) {
      _visualShuffleList = group.members.map((m) => m.name).toList();
    }
  }

  @override
  void dispose() {
    _intermediateTimer?.cancel();
    _iconSpinController.dispose();
    _cardShuffleController.dispose();
    super.dispose();
  }

  void _startShuffle() {
    if (_isShuffling) return;

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

    final settings = ref.read(settingsProvider);
    _audioHapticService.playLaunch(settings);

    // Requirement 7 & 9: Compute final result using Fisher-Yates shuffle
    final finalResult = ref
        .read(shuffleServiceProvider)
        .shuffle(group, previousOrder: _result.isNotEmpty ? _result : null);

    setState(() {
      _isShuffling = true;
      _showResult = false;
      _visualShuffleList = group.members.map((m) => m.name).toList();
    });

    _iconSpinController.forward(from: 0);

    // Rapid intermediate visual permutations
    int stepCount = 0;
    _intermediateTimer?.cancel();
    _intermediateTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      stepCount++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (stepCount < 10) {
        // Visual intermediate shuffle permutation (visual effect only)
        final temp = List<String>.from(_visualShuffleList);
        temp.shuffle(_visualRandom);
        setState(() {
          _visualShuffleList = temp;
        });
        _audioHapticService.playSpinTick(settings);
      } else {
        // Conclude visual shuffling and reveal actual Fisher-Yates result
        timer.cancel();
        _finalizeShuffle(group, finalResult.shuffledOrder);
      }
    });
  }

  void _finalizeShuffle(Group group, List<String> finalOrder) {
    ref.read(settingsProvider.notifier).incrementShuffles();
    ref.read(historyProvider.notifier).addEntry(
          HistoryEntry(
            groupId: group.id,
            groupName: group.name,
            result: finalOrder,
          ),
        );

    final settings = ref.read(settingsProvider);
    _audioHapticService.playResult(settings);

    setState(() {
      _result = List.from(finalOrder);
      _visualShuffleList = List.from(finalOrder);
      _isShuffling = false;
      _showResult = true;
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeaderIcon(theme, group),
                  const SizedBox(height: 24),
                  if (_isShuffling)
                    _buildVisualShufflingList(theme)
                  else if (_showResult)
                    ..._buildResultList(theme)
                  else
                    _buildInitialList(theme, group),
                  const SizedBox(height: 32),
                  _buildBottomActions(theme, group),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(ThemeData theme, Group group) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _iconSpinController,
          builder: (context, child) {
            final value = _iconSpinController.value;
            final rotation = value * 4 * pi;
            final scale = 1.0 + sin(value * 3 * pi) * 0.15;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(rotation)
                ..scale(scale, scale, 1.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: _isShuffling ? 28 : 16,
                      spreadRadius: _isShuffling ? 6 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shuffle_rounded,
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          _isShuffling
              ? 'SHUFFLING...'
              : (_showResult ? 'Randomized Order' : 'Ready to Shuffle'),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${group.memberCount} members in ${_groupName.isNotEmpty ? _groupName : 'Group'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Section 8 & 9: Real visual shuffling animation displaying card movements
  Widget _buildVisualShufflingList(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        LinearProgressIndicator(
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 20),
        ...List.generate(_visualShuffleList.length.clamp(0, 10), (index) {
          final name = _visualShuffleList[index];
          return Card(
            key: ValueKey('shuffle_visual_$name'),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                Icons.swap_vert_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          )
              .animate(key: ValueKey('anim_${name}_$index'))
              .slideY(
                begin: (index % 2 == 0 ? 0.3 : -0.3),
                duration: 120.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
                duration: 120.ms,
              );
        }),
      ],
    );
  }

  Widget _buildInitialList(ThemeData theme, Group group) {
    return Column(
      children: group.members.take(10).map((m) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(m.name),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildResultList(ThemeData theme) {
    final rankEmojis = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣', '🔟'];

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shuffle Complete!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn().scale(begin: const Offset(0.85, 0.85)),
      const SizedBox(height: 20),
      ...List.generate(_result.length, (index) {
        final name = _result[index];
        final rankIcon = index < rankEmojis.length
            ? rankEmojis[index]
            : '${index + 1}.';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: index == 0 ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: index == 0
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            leading: Text(
              rankIcon,
              style: TextStyle(fontSize: index < 3 ? 26 : 20),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: index == 0 ? FontWeight.bold : FontWeight.w600,
                fontSize: index == 0 ? 18 : 16,
                color: index == 0 ? theme.colorScheme.primary : null,
              ),
            ),
            trailing: index == 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'WINNER',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  )
                : null,
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + (index * 40)))
            .slideY(
              begin: 0.15,
              end: 0,
              delay: Duration(milliseconds: 100 + (index * 40)),
              curve: Curves.easeOutCubic,
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
            icon: Icon(_showResult ? Icons.refresh_rounded : Icons.shuffle_rounded),
            label: Text(
              _isShuffling
                  ? 'SHUFFLING...'
                  : (_showResult ? 'SHUFFLE AGAIN' : 'START SHUFFLE'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ).animate().fadeIn(delay: _showResult ? 200.ms : Duration.zero),
        if (_showResult) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copy Result'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share Result'),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
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
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _resultAsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied to clipboard')),
    );
  }

  void _shareResult() {
    HapticFeedback.selectionClick();
    Share.share(
      '🎲 Shuffle Master Result - ${_groupName.isNotEmpty ? _groupName : 'Group'}\n\n$_resultAsText',
    );
  }
}
