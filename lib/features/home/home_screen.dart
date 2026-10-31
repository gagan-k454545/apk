import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../providers/providers.dart';
import 'widgets/app_header.dart';
import 'widgets/feature_card.dart';
import 'widgets/group_card.dart';
import 'widgets/hero_decision_card.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/stat_tile.dart';

/// Faithful, pixel-aligned replication of the Shuffle Master Home Screen.
/// Built using the modular components:
/// - [AppHeader]
/// - [HeroDecisionCard]
/// - [FeatureCard] (Name Shuffle & Coin Toss)
/// - [QuickActionTile] (Shuffle names, Toss Coin, Create Group, View History)
/// - [StatTile] (Names, Groups, Shuffles, Tosses metrics)
/// - [GroupCard] (Classmates, Project Team, Game Night)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groups = ref.watch(groupsProvider);
    final history = ref.watch(historyProvider);
    final coinTossHistory = ref.watch(coinTossProvider);

    final totalNames = groups.fold<int>(0, (sum, g) => sum + g.memberCount);
    final totalGroups = groups.length;
    final totalShuffles = history.length;
    final totalCoinTosses = coinTossHistory.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. Top Header Area ──
            const SliverToBoxAdapter(
              child: AppHeader(),
            ),

            // ── 2. Hero Decision Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: HeroDecisionCard(
                  onGetStarted: () {
                    if (groups.isNotEmpty) {
                      context.push('/shuffle/${groups.first.id}');
                    } else {
                      context.push('/shuffle/cricket-6');
                    }
                  },
                ),
              ),
            ),

            // ── 3. Two Main Feature Cards (Name Shuffle & Coin Toss) ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    // Card 1: Name Shuffle
                    Expanded(
                      child: FeatureCard(
                        title: 'Name Shuffle',
                        description:
                            'Randomize a list of names using pure Fisher-Yates algorithm.',
                        icon: Icons.shuffle_rounded,
                        badgeText: 'Fair & Instant',
                        badgeIcon: Icons.verified_user_rounded,
                        backgroundColor: isDark
                            ? const Color(0xFF222F26)
                            : const Color(0xFFEDF4EB),
                        iconBoxColor: PremiumDesignTokens.mossDark,
                        floatingPills: const ['Aarav', 'Neha', 'Karan'],
                        onTap: () {
                          if (groups.isNotEmpty) {
                            context.push('/shuffle/${groups.first.id}');
                          } else {
                            context.push('/shuffle/cricket-6');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Card 2: Coin Toss
                    Expanded(
                      child: FeatureCard(
                        title: 'Coin Toss',
                        description:
                            'Make a quick 50/50 heads-or-tails decision with 3D animation.',
                        icon: Icons.monetization_on_rounded,
                        badgeText: '3D Animation',
                        badgeIcon: Icons.public_rounded,
                        backgroundColor: isDark
                            ? const Color(0xFF33271A)
                            : const Color(0xFFFCF2E8),
                        iconBoxColor: const Color(0xFFD67E2D),
                        hasCoinGraphic: true,
                        onTap: () => context.go('/coin_toss'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 4. Quick Actions Section Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    PressableScale(
                      onTap: () => context.go('/groups'),
                      child: const Row(
                        children: [
                          Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: PremiumDesignTokens.sageMedium,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: PremiumDesignTokens.sageMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4 Rounded Pastel Quick Action Tiles
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.shuffle_rounded,
                        label: 'Shuffle names',
                        backgroundColor: isDark
                            ? const Color(0xFF222F26)
                            : const Color(0xFFEDF4EB),
                        iconColor: PremiumDesignTokens.mossDark,
                        onTap: () {
                          if (groups.isNotEmpty) {
                            context.push('/shuffle/${groups.first.id}');
                          } else {
                            context.push('/shuffle/cricket-6');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.monetization_on_rounded,
                        label: 'Toss Coin',
                        backgroundColor: isDark
                            ? const Color(0xFF33271A)
                            : const Color(0xFFFCF2E8),
                        iconColor: const Color(0xFFD67E2D),
                        onTap: () => context.go('/coin_toss'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.group_add_outlined,
                        label: 'Create Group',
                        backgroundColor: isDark
                            ? const Color(0xFF1E2D33)
                            : const Color(0xFFE8F4F8),
                        iconColor: const Color(0xFF2A7C98),
                        onTap: () => context.go('/groups'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.history_rounded,
                        label: 'View History',
                        backgroundColor: isDark
                            ? const Color(0xFF2E2236)
                            : const Color(0xFFF3EBF8),
                        iconColor: const Color(0xFF884DB0),
                        onTap: () => context.go('/history'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 5. Summary Stats Pills ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.person_rounded,
                        count: '$totalNames',
                        label: 'Names',
                        color: const Color(0xFF3E754C),
                        backgroundColor: isDark
                            ? const Color(0xFF202B23)
                            : const Color(0xFFEBF3EA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        icon: Icons.groups_rounded,
                        count: '$totalGroups',
                        label: 'Groups',
                        color: const Color(0xFFB8682F),
                        backgroundColor: isDark
                            ? const Color(0xFF2E231B)
                            : const Color(0xFFFBF1E7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        icon: Icons.shuffle_rounded,
                        count: '$totalShuffles',
                        label: 'Shuffles',
                        color: const Color(0xFF2A7C98),
                        backgroundColor: isDark
                            ? const Color(0xFF1C282F)
                            : const Color(0xFFE8F3F7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatTile(
                        icon: Icons.monetization_on_rounded,
                        count: '$totalCoinTosses',
                        label: 'Tosses',
                        color: const Color(0xFF854CB0),
                        backgroundColor: isDark
                            ? const Color(0xFF2B2033)
                            : const Color(0xFFF3EBF8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 6. "Your Groups" Section Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 20,
                      color: PremiumDesignTokens.mossDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Groups',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    PressableScale(
                      onTap: () => context.go('/groups'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PremiumDesignTokens.mossDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'New Group',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
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

            // Horizontal Groups Cards List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 112,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: groups.length.clamp(0, 6),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final g = groups[index];
                    final icon = _getGroupIcon(g.name);
                    final iconColor = _getGroupIconColor(index);

                    return GroupCard(
                      name: g.name,
                      memberCount: g.memberCount,
                      icon: icon,
                      iconColor: iconColor,
                      onTap: () => context.push('/shuffle/${g.id}'),
                      onMenuTap: () => context.push('/group/${g.id}'),
                    );
                  },
                ),
              ),
            ),

            // Bottom Breathing Room above Bottom Navigation Bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  static IconData _getGroupIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cricket') || lower.contains('sport')) {
      return Icons.sports_cricket_rounded;
    }
    if (lower.contains('class') || lower.contains('school')) {
      return Icons.school_rounded;
    }
    if (lower.contains('game')) {
      return Icons.sports_esports_rounded;
    }
    return Icons.people_rounded;
  }

  static Color _getGroupIconColor(int index) {
    const colors = [
      Color(0xFF2E6B47),
      Color(0xFFBD6D35),
      Color(0xFF297996),
      Color(0xFF8B4CB2),
    ];
    return colors[index % colors.length];
  }
}
