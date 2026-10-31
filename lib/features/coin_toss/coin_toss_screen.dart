import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/audio_haptic_service.dart';
import '../../core/shuffle/coin_toss_engine.dart';
import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'widgets/coin_3d_widget.dart';

/// Redesigned Coin Toss Screen:
/// - True end-to-end CSPRNG randomness with anti-streak protection
/// - Three fair random outcomes: HEADS, TAILS, and NO RESULT (lands on edge in the middle)
/// - Mid-air "TOSSING..." state so no result is shown in the middle of a flip
/// - Header with sound & haptic 44px toggles
/// - Level 1 Stage Card with 3D Gold Crown coin, result block
/// - Primary toss button with tactile scale
/// - Statistics card: 3 equal tiles (Heads, Tails, No Result) + 3-way split bar + sample note
/// - Recent Tosses: latest 10, slide-in animation, clear all & individual delete
/// - Bottom nav clearance (106 + bottomInset)
class CoinTossScreen extends ConsumerStatefulWidget {
  const CoinTossScreen({super.key});

  @override
  ConsumerState<CoinTossScreen> createState() => _CoinTossScreenState();
}

class _CoinTossScreenState extends ConsumerState<CoinTossScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late TossPlan _currentPlan;
  CoinFace _currentFace = CoinFace.heads;

  bool _isTossing = false;
  bool _hasResult = false;
  CoinTossEntry? _pendingEntry;
  CoinTossEntry? _lastResult;

  // Sound & Haptic service
  final AudioHapticService _audioHapticService = const AudioHapticService();

  // Flags to avoid repeated sound triggers in the same animation cycle
  bool _didLaunch = false;
  bool _didApexTick = false;
  bool _didLand = false;
  bool _didBounce1 = false;
  bool _didBounce2 = false;

  @override
  void initState() {
    super.initState();
    // Default initial resting plan (heads)
    _currentPlan = const TossPlan(
      result: CoinFace.heads,
      startFace: CoinFace.heads,
      halfTurns: 0,
      durationMs: 1800,
      tiltY: 0,
      driftZ: 0,
      height: 180,
      bounces: 3,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animationController.addListener(_handleAnimationProgress);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleTossCompleted();
      }
    });

    // If history exists, reflect last result on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = ref.read(coinTossProvider);
      if (history.isNotEmpty && mounted) {
        final last = history.first;
        CoinFace lastFace;
        switch (last.outcome) {
          case CoinSide.heads:
            lastFace = CoinFace.heads;
            break;
          case CoinSide.tails:
            lastFace = CoinFace.tails;
            break;
          case CoinSide.noResult:
            lastFace = CoinFace.noResult;
            break;
        }

        setState(() {
          _lastResult = last;
          _hasResult = true;
          _currentFace = lastFace;
          _currentPlan = TossPlan(
            result: _currentFace,
            startFace: _currentFace,
            halfTurns: 0,
            durationMs: 1800,
            tiltY: 0,
            driftZ: 0,
            height: 180,
            bounces: 3,
            targetRestingAngle: _currentFace == CoinFace.heads
                ? 0.0
                : (_currentFace == CoinFace.tails ? 180.0 : 90.0),
          );
        });
      }
    });
  }

  void _handleAnimationProgress() {
    final v = _animationController.value;
    final settings = ref.read(settingsProvider);

    // Timeline audio triggers
    if (v >= 0.05 && !_didLaunch) {
      _didLaunch = true;
      _audioHapticService.playLaunch(settings);
    } else if (v >= 0.44 && !_didApexTick) {
      _didApexTick = true;
      _audioHapticService.playSpinTick(settings);
    } else if (v >= 0.78 && !_didLand) {
      _didLand = true;
      _audioHapticService.playLanding(settings);
    } else if (v >= 0.88 && !_didBounce1) {
      _didBounce1 = true;
      _audioHapticService.playBounce(settings, 0.6);
    } else if (v >= 0.94 && !_didBounce2) {
      _didBounce2 = true;
      _audioHapticService.playBounce(settings, 0.36);
    }
  }

  Future<void> _handleTossCompleted() async {
    if (!mounted) return;

    final entryToSave = _pendingEntry;
    if (entryToSave != null) {
      await ref.read(coinTossProvider.notifier).saveTossResult(entryToSave);
    }

    final settings = ref.read(settingsProvider);
    _audioHapticService.playResult(settings);

    if (mounted) {
      setState(() {
        _isTossing = false;
        _hasResult = true;
        _lastResult = entryToSave;
        _currentFace = _currentPlan.result;
        _pendingEntry = null;
      });
    }
  }

  @override
  void dispose() {
    if (_isTossing && _pendingEntry != null) {
      ref.read(coinTossProvider.notifier).saveTossResult(_pendingEntry!);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _startToss() {
    if (_isTossing) return;

    _audioHapticService.unlock();

    // 1. Decide outcome via unbiased CSPRNG with anti-streak protection
    final plan = CoinTossEngine.planToss(_currentFace);
    CoinSide side;
    switch (plan.result) {
      case CoinFace.heads:
        side = CoinSide.heads;
        break;
      case CoinFace.tails:
        side = CoinSide.tails;
        break;
      case CoinFace.noResult:
        side = CoinSide.noResult;
        break;
    }

    final entry = CoinTossEntry(
      isHeads: side == CoinSide.heads,
      outcome: side,
    );

    _didLaunch = false;
    _didApexTick = false;
    _didLand = false;
    _didBounce1 = false;
    _didBounce2 = false;

    setState(() {
      _isTossing = true;
      _hasResult = false;
      _currentPlan = plan;
      _pendingEntry = entry;
    });

    _animationController.duration = Duration(milliseconds: plan.durationMs);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final totalBottomPadding = 64.0 + 18.0 + bottomInset + 24.0;

    final settings = ref.watch(settingsProvider);
    final history = ref.watch(coinTossProvider);
    final notifier = ref.read(coinTossProvider.notifier);

    final totalTosses = notifier.totalTosses;
    final headsCount = notifier.headsCount;
    final tailsCount = notifier.tailsCount;
    final noResultCount = notifier.noResultCount;
    final headsPct = notifier.headsPercentage;
    final tailsPct = notifier.tailsPercentage;
    final noResultPct = notifier.noResultPercentage;

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coin Toss',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: PremiumDesignTokens.textStrong,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'True Random · Anti-Streak · 3-Way Fair',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: PremiumDesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sound Toggle
                    PressableScale(
                      onTap: () =>
                          ref.read(settingsProvider.notifier).toggleSound(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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
                        child: Icon(
                          settings.soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          size: 20,
                          color: settings.soundEnabled
                              ? PremiumDesignTokens.forestDark
                              : PremiumDesignTokens.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Haptics Toggle
                    PressableScale(
                      onTap: () =>
                          ref.read(settingsProvider.notifier).toggleHaptic(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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
                        child: Icon(
                          settings.hapticEnabled
                              ? Icons.vibration_rounded
                              : Icons.phonelink_erase_rounded,
                          size: 20,
                          color: settings.hapticEnabled
                              ? PremiumDesignTokens.forestDark
                              : PremiumDesignTokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Main Stage Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: PremiumDesignTokens.gradPeachCard,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: PremiumDesignTokens.cardBorder,
                      width: PremiumDesignTokens.cardBorderWidth,
                    ),
                    boxShadow: PremiumDesignTokens.cardShadow,
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  child: Column(
                    children: [
                      // Top Pill: "FAIR RANDOM DECISION"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            PremiumDesignTokens.rPill,
                          ),
                          border: Border.all(
                            color: PremiumDesignTokens.innerBorder,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D1B4332),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: PremiumDesignTokens.gold500,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'END-TO-END FAIR RANDOM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: PremiumDesignTokens.textStrong,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3D Coin Stage Area (~260px)
                      Coin3DWidget(
                        animationController: _animationController,
                        plan: _currentPlan,
                        isTossing: _isTossing,
                        hasResult: _hasResult,
                        onTap: _startToss,
                      ),
                      const SizedBox(height: 10),

                      // Result Block below Coin (Shows mid-air Tossing in the middle or settled result)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: _buildResultBlock(),
                      ),
                      const SizedBox(height: 18),

                      // Primary Button: "TOSS COIN" / "TOSS AGAIN"
                      PressableScale(
                        onTap: _isTossing ? null : _startToss,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: PremiumDesignTokens.gradPrimary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: PremiumDesignTokens.shadowButton,
                          ),
                          child: Center(
                            child: _isTossing
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'FLIPPING IN MID-AIR...',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
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
                                        _hasResult
                                            ? 'TOSS AGAIN'
                                            : 'TOSS COIN',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Statistics Section (3 equal tiles for Heads, Tails, No Result + 3-way split bar)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: PremiumDesignTokens.cardBorder,
                      width: PremiumDesignTokens.cardBorderWidth,
                    ),
                    boxShadow: PremiumDesignTokens.cardShadow,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Total counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EDE2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: PremiumDesignTokens.innerBorder,
                              ),
                            ),
                            child: Text(
                              'Total: $totalTosses',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: PremiumDesignTokens.forestDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Three equal outcome tiles: Heads, Tails, No Result
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Heads',
                              value: headsCount,
                              percentText: totalTosses > 0
                                  ? '(${headsPct.toStringAsFixed(0)}%)'
                                  : '(0%)',
                              icon: Icons.workspace_premium_rounded,
                              iconColor: PremiumDesignTokens.gold500,
                              iconBg: const Color(0xFFFDF7E7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              label: 'Tails',
                              value: tailsCount,
                              percentText: totalTosses > 0
                                  ? '(${tailsPct.toStringAsFixed(0)}%)'
                                  : '(0%)',
                              icon: Icons.stars_rounded,
                              iconColor: PremiumDesignTokens.teal600,
                              iconBg: PremiumDesignTokens.teal50,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              label: 'No Result',
                              value: noResultCount,
                              percentText: totalTosses > 0
                                  ? '(${noResultPct.toStringAsFixed(0)}%)'
                                  : '(0%)',
                              icon: Icons.view_headline_rounded,
                              iconColor: const Color(0xFFD97706),
                              iconBg: const Color(0xFFFEF3C7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 3-Segment Animated Split Bar (Heads in Gold, Tails in Teal, No Result in Amber)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color(0xFFF0EAE1),
                          child: totalTosses == 0
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    if (headsCount > 0)
                                      Expanded(
                                        flex: headsCount,
                                        child: Container(
                                          color: PremiumDesignTokens.gold500,
                                        ),
                                      ),
                                    if (tailsCount > 0)
                                      Expanded(
                                        flex: tailsCount,
                                        child: Container(
                                          color: PremiumDesignTokens.teal600,
                                        ),
                                      ),
                                    if (noResultCount > 0)
                                      Expanded(
                                        flex: noResultCount,
                                        child: Container(
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        'Balanced 3-way random: Heads, Tails, and No Result (edge). Anti-streak protection active.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: PremiumDesignTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Recent Tosses Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Tosses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesignTokens.textStrong,
                      ),
                    ),
                    if (history.isNotEmpty)
                      GestureDetector(
                        onTap: () => _confirmClearHistory(context),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          height: 44,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Clear all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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

            // Recent Tosses List
            if (history.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 38,
                          color: PremiumDesignTokens.textMuted,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No recent tosses yet',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: PremiumDesignTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RecentTossRow(
                          key: ValueKey(entry.id),
                          entry: entry,
                          onDelete: () =>
                              ref.read(coinTossProvider.notifier).deleteEntry(entry.id),
                        ),
                      );
                    },
                    childCount: history.length > 10 ? 10 : history.length,
                  ),
                ),
              ),

            // Bottom Nav Clearance
            SliverToBoxAdapter(
              child: SizedBox(height: totalBottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  /// Result block below coin displaying live state or final outcome
  Widget _buildResultBlock() {
    if (_isTossing) {
      return Column(
        key: const ValueKey('tossing'),
        children: [
          const Text(
            'TOSSING...',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: PremiumDesignTokens.textStrong,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumDesignTokens.innerBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PremiumDesignTokens.gold500,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Deciding in mid-air...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: PremiumDesignTokens.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (!_hasResult || _lastResult == null) {
      return const Text(
        'Tap the coin or press Toss',
        key: ValueKey('idle'),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: PremiumDesignTokens.textStrong,
        ),
      );
    }

    final outcome = _lastResult!.outcome;
    final isHeads = outcome == CoinSide.heads;
    final isNoResult = outcome == CoinSide.noResult;

    final resultTitle = isNoResult ? 'NO RESULT' : (isHeads ? 'HEADS' : 'TAILS');
    final resultColor = isNoResult
        ? const Color(0xFFD97706)
        : (isHeads
            ? const Color(0xFFBF7A08)
            : PremiumDesignTokens.green700);

    final subtext = isNoResult
        ? 'Coin landed on edge in the middle · Toss again!'
        : 'Decided by secure random';

    return Column(
      key: ValueKey('result_${_lastResult!.id}'),
      children: [
        Text(
          resultTitle,
          style: TextStyle(
            fontSize: isNoResult ? 30 : 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: resultColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNoResult
                  ? const Color(0xFFFDE68A)
                  : PremiumDesignTokens.innerBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A1B4332),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNoResult
                    ? Icons.view_headline_rounded
                    : (isHeads
                        ? Icons.workspace_premium_rounded
                        : Icons.stars_rounded),
                size: 13,
                color: resultColor,
              ),
              const SizedBox(width: 5),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isNoResult
                      ? const Color(0xFF92400E)
                      : PremiumDesignTokens.forestDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clear Coin Toss History?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesignTokens.textStrong,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will clear all recorded tosses and reset counters.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: PremiumDesignTokens.textBody,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(
                          color: PremiumDesignTokens.cardBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(modalCtx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: PremiumDesignTokens.textStrong,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ref.read(coinTossProvider.notifier).clearHistory();
                        Navigator.pop(modalCtx);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Statistics Sub-tile
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.percentText,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final int value;
  final String percentText;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumDesignTokens.innerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, _) {
              return Text(
                '${animatedVal.round()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesignTokens.textStrong,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: PremiumDesignTokens.textMuted,
                ),
              ),
              if (percentText.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  percentText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: PremiumDesignTokens.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent Toss List Item
class _RecentTossRow extends StatelessWidget {
  const _RecentTossRow({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  final CoinTossEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final outcome = entry.outcome;
    final isHeads = outcome == CoinSide.heads;
    final isNoResult = outcome == CoinSide.noResult;

    final timeStr = DateFormat('h:mm a').format(entry.tossedAt);

    Color bgStart;
    Color bgEnd;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String labelText;

    if (isNoResult) {
      bgStart = const Color(0xFFFEF3C7);
      bgEnd = const Color(0xFFFDE68A);
      borderColor = const Color(0xFFF59E0B);
      iconColor = const Color(0xFFB45309);
      iconData = Icons.view_headline_rounded;
      labelText = 'NO RESULT';
    } else if (isHeads) {
      bgStart = const Color(0xFFFCE29A);
      bgEnd = const Color(0xFFE9B44C);
      borderColor = const Color(0xFFD99A22);
      iconColor = const Color(0xFF6B4302);
      iconData = Icons.workspace_premium_rounded;
      labelText = 'HEADS';
    } else {
      bgStart = const Color(0xFFE2EEDC);
      bgEnd = const Color(0xFFCFE0CB);
      borderColor = PremiumDesignTokens.green300;
      iconColor = PremiumDesignTokens.green800;
      iconData = Icons.stars_rounded;
      labelText = 'TAILS';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumDesignTokens.cardBorder,
          width: PremiumDesignTokens.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C1B4332),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Left Face Icon Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [bgStart, bgEnd]),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Icon(iconData, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),

          // Result label bold + Time muted
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: PremiumDesignTokens.textStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$timeStr · Today',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: PremiumDesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Delete Hit Area (X button)
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: PremiumDesignTokens.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
