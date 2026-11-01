import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/audio_haptic_service.dart';
import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/premium_widgets.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'widgets/bottom_action_buttons.dart';
import 'widgets/hero_shuffle_card.dart';
import 'widgets/premium_top_bar.dart';

/// Premium Randomized Order Result Screen for the "Cricket 6" shuffle flow.
/// Faithful visual replication of the cream & muted forest green reference identity.
class PremiumShuffleResultScreen extends ConsumerStatefulWidget {
  const PremiumShuffleResultScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  ConsumerState<PremiumShuffleResultScreen> createState() =>
      _PremiumShuffleResultScreenState();
}

class _PremiumShuffleResultScreenState
    extends ConsumerState<PremiumShuffleResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconSpinController;

  bool _isShuffling = false;
  bool _isSaved = false;
  List<String> _result = [];
  List<String> _visualShuffleList = [];
  String _groupName = 'Shuffle';
  int _memberCount = 0;
  int _shuffleStepCount = 0;

  Timer? _intermediateTimer;
  final AudioHapticService _audioHapticService = const AudioHapticService();

  @override
  void initState() {
    super.initState();
    _iconSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadGroup();
  }

  void _loadGroup() {
    final groups = ref.read(groupsProvider);
    final Group? group = groups.where((g) => g.id == widget.groupId).firstOrNull ??
        (groups.isNotEmpty ? groups.first : null);

    if (group != null) {
      _groupName = group.name;
      final memberNames = group.members.map((m) => m.name).toList();
      _memberCount = memberNames.length;
      _result = List<String>.from(memberNames);
      _visualShuffleList = List<String>.from(memberNames);
    } else {
      _groupName = 'Names';
      _memberCount = 0;
      _result = [];
      _visualShuffleList = [];
    }
  }

  @override
  void dispose() {
    _intermediateTimer?.cancel();
    _iconSpinController.dispose();
    super.dispose();
  }

  void _startShuffle() {
    if (_isShuffling) return;

    final groups = ref.read(groupsProvider);
    final Group? group = groups.where((g) => g.id == widget.groupId).firstOrNull ??
        (groups.isNotEmpty ? groups.first : null);

    if (group == null || group.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add names to this group before shuffling.'),
        ),
      );
      return;
    }

    final settings = ref.read(settingsProvider);
    _audioHapticService.playLaunch(settings);

    // Compute randomized order using Fisher-Yates algorithm
    final finalResult = ref.read(shuffleServiceProvider).shuffle(
          group,
          previousOrder: _result.isNotEmpty ? _result : null,
        );

    setState(() {
      _isShuffling = true;
      _isSaved = false;
      _shuffleStepCount = 0;
      _visualShuffleList = List<String>.from(_result);
    });

    _iconSpinController.forward(from: 0);

    // Responsive intermediate permutation with physical card riffle feel
    _intermediateTimer?.cancel();
    _intermediateTimer =
        Timer.periodic(const Duration(milliseconds: 85), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _shuffleStepCount++;
      if (_shuffleStepCount < 8) {
        final temp = fisherYates(_visualShuffleList);
        setState(() {
          _visualShuffleList = temp;
        });
        _audioHapticService.playSpinTick(settings);
      } else {
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
      _memberCount = finalOrder.length;
      _isShuffling = false;
      _shuffleStepCount = 0;
    });
  }

  void _saveOrder() {
    if (_result.isEmpty) return;

    final groups = ref.read(groupsProvider);
    final Group? group = groups.where((g) => g.id == widget.groupId).firstOrNull ??
        (groups.isNotEmpty ? groups.first : null);

    final groupId = group?.id ?? 'custom';
    final groupName = group?.name ?? _groupName;

    ref.read(historyProvider.notifier).addEntry(
          HistoryEntry(
            groupId: groupId,
            groupName: groupName,
            result: _result,
          ),
        );

    final settings = ref.read(settingsProvider);
    _audioHapticService.playResult(settings);
    HapticFeedback.mediumImpact();

    // Tactile button morph state
    setState(() {
      _isSaved = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Order saved for "$_groupName"'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sortAlphabetical() {
    if (_isShuffling) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      _visualShuffleList = List<String>.from(_result);
      _isSaved = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.sort_by_alpha_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Names sorted alphabetically (A-Z)'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1800),
      ),
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
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Ranking copied to clipboard'),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    HapticFeedback.selectionClick();
    Share.share(
      '🏆 Randomized Order - $_groupName\n\n$_resultAsText\n\nRandomized with Shuffle Master',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // A & B: Top Bar with Back, GroupChip ("Cricket 6"), Share, Copy & Sort A-Z
            PremiumTopBar(
              groupName: _groupName,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              onCopy: _copyResult,
              onShare: _shareResult,
              onSortAlphabetical: _isShuffling ? null : _sortAlphabetical,
            ),

            // Scrollable Content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // C, D, E & F: Hero Area, Title, Subtitle, and Success Badge
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: HeroShuffleCard(
                        title: _isShuffling
                            ? 'Shuffling Names...'
                            : 'Randomized Order',
                        subtitle: '$_memberCount members in $_groupName',
                        isShuffling: _isShuffling,
                        iconSpinController: _iconSpinController,
                      ),
                    ),
                  ),

                  // G: Ranked List with Winner Emphasis & Lower Rows
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listToDisplay =
                              _isShuffling ? _visualShuffleList : _result;

                          if (index >= listToDisplay.length) return null;
                          final name = listToDisplay[index];
                          final rank = index + 1;

                          // Emil Kowalski Motion: Staggered reveal under 240ms
                          final delayMs = (index * 35).clamp(0, 240);

                          Widget cardWidget;
                          if (rank == 1 && !_isShuffling) {
                            cardWidget = WinnerMemberCard(
                              name: name,
                              onTap: () => _showMemberDetail(name, 1),
                            );
                          } else {
                            cardWidget = RankedMemberCard(
                              name: name,
                              rank: rank,
                              onTap: () => _showMemberDetail(name, rank),
                            );
                          }

                          // Physical deck riffling during active shuffle
                          if (_isShuffling && !reduceMotion) {
                            final riffleX = (index % 2 == 0 ? 1 : -1) *
                                3.5 *
                                sin(_shuffleStepCount * 0.9);
                            cardWidget = Transform.translate(
                              offset: Offset(riffleX, 0),
                              child: cardWidget,
                            );
                          }

                          if (reduceMotion) {
                            return cardWidget;
                          }

                          return _StaggeredRowReveal(
                            delay: Duration(milliseconds: delayMs),
                            child: cardWidget,
                          );
                        },
                        childCount: _isShuffling
                            ? _visualShuffleList.length
                            : _result.length,
                      ),
                    ),
                  ),

                  // Bottom padding so list scrolls comfortably above buttons
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // H: Bottom Actions (Shuffle Again & Save Order)
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomActionButtons(
          onShuffleAgain: _isShuffling ? null : _startShuffle,
          onSaveOrder: _isShuffling ? null : _saveOrder,
          isShuffling: _isShuffling,
          isSaved: _isSaved,
        ),
      ),
    );
  }

  void _showMemberDetail(String name, int rank) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2821)
                : PremiumDesignTokens.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334336)
                  : PremiumDesignTokens.hairline,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 28,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF455A4B)
                      : const Color(0xFFD6CEBF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rank == 1
                          ? const Color(0xFFF7E6C2)
                          : PremiumDesignTokens.sageLight,
                      border: Border.all(
                        color: rank == 1
                            ? PremiumDesignTokens.goldBorder
                            : PremiumDesignTokens.sageBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: rank == 1
                              ? PremiumDesignTokens.goldText
                              : PremiumDesignTokens.sageText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          rank == 1
                              ? '🏆 Winner / 1st in Order'
                              : 'Rank #$rank in $_groupName',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: PremiumDesignTokens.mossDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Emil Kowalski Staggered Row Animator:
/// Animates opacity and translation only.
/// Strict ease-out curve, under 220ms duration.
class _StaggeredRowReveal extends StatefulWidget {
  const _StaggeredRowReveal({
    required this.delay,
    required this.child,
  });

  final Duration delay;
  final Widget child;

  @override
  State<_StaggeredRowReveal> createState() => _StaggeredRowRevealState();
}

class _StaggeredRowRevealState extends State<_StaggeredRowReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PremiumDesignTokens.durationEntrance,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: PremiumDesignTokens.easeOutCubic,
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
