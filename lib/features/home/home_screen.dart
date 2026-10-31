import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

/// Pixel-faithful replication of the Shuffle Master Home Screen matching the Master Prompt:
/// - Page Background: warm cream (--bg-app #FBF6EE) + subtle radial peach glow
/// - Staggered 380ms entrance fade-up
/// - Section 5.2 AppHeader
/// - Section 5.3 HeroDecisionCard (Playfair Display 800, 3D box, floating name chips)
/// - Section 5.4 Feature Cards (Name Shuffle & Coin Toss)
/// - Section 5.5 Quick Actions (4 pastel squircle tiles)
/// - Section 5.6 Stats Strip (single card with 4 columns, dividers, count-up animation)
/// - Section 5.7 Your Groups (header, + New Group button, horizontal cards, empty state)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final groups = ref.watch(groupsProvider);
    final history = ref.watch(historyProvider);
    final coinTossHistory = ref.watch(coinTossProvider);

    final totalNames = groups.fold<int>(0, (sum, g) => sum + g.memberCount);
    final totalGroups = groups.length;
    final totalShuffles = history.length;
    final totalCoinTosses = coinTossHistory.length;

    Widget wrapStagger(Widget child, int index) {
      if (reduceMotion) return child;
      return child
          .animate()
          .fadeIn(
            duration: const Duration(milliseconds: 380),
            curve: const Cubic(0.2, 0.8, 0.2, 1.0),
            delay: Duration(milliseconds: 60 * index),
          )
          .slideY(
            begin: 0.08,
            end: 0,
            duration: const Duration(milliseconds: 380),
            curve: const Cubic(0.2, 0.8, 0.2, 1.0),
            delay: Duration(milliseconds: 60 * index),
          );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141D16)
          : PremiumDesignTokens.bgApp,
      body: Stack(
        children: [
          // Background subtle peach and mint radial glows (Section 4.2)
          if (!isDark) ...[
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDesignTokens.green100.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      PremiumDesignTokens.bgAppGlow.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Single Scroll Column
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header Row (index 0)
                SliverToBoxAdapter(
                  child: wrapStagger(const AppHeader(), 0),
                ),

                // 2. Hero Card (index 1)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: wrapStagger(
                      HeroDecisionCard(
                        onGetStarted: () {
                          if (groups.isNotEmpty) {
                            context.push('/shuffle/${groups.first.id}');
                          } else {
                            context.push('/shuffle/cricket-6');
                          }
                        },
                      ),
                      1,
                    ),
                  ),
                ),

                // 3. Two Main Feature Cards (index 2)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  sliver: SliverToBoxAdapter(
                    child: wrapStagger(
                      Row(
                        children: [
                          // Card A: Name Shuffle
                          Expanded(
                            child: FeatureCard(
                              title: 'Name Shuffle',
                              description:
                                  'Randomize a list of names using pure Fisher-Yates algorithm.',
                              icon: Icons.shuffle_rounded,
                              badgeText: 'Fair & Instant',
                              badgeIcon: Icons.verified_user_rounded,
                              backgroundColor: PremiumDesignTokens.green100,
                              backgroundGradient:
                                  PremiumDesignTokens.gradMintCard,
                              iconBoxColor: PremiumDesignTokens.green800,
                              iconBoxGradient:
                                  PremiumDesignTokens.gradPrimary,
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
                          const SizedBox(width: 10),

                          // Card B: Coin Toss
                          Expanded(
                            child: FeatureCard(
                              title: 'Coin Toss',
                              description:
                                  'Make a quick 50/50 heads-or-tails decision with 3D animation.',
                              icon: Icons.monetization_on_rounded,
                              badgeText: '3D Animation',
                              badgeIcon: Icons.view_in_ar_rounded,
                              backgroundColor: PremiumDesignTokens.peach100,
                              backgroundGradient:
                                  PremiumDesignTokens.gradPeachCard,
                              iconBoxColor: PremiumDesignTokens.orange500,
                              iconBoxGradient:
                                  PremiumDesignTokens.gradOrange,
                              isPeachCard: true,
                              hasCoinGraphic: true,
                              onTap: () => context.go('/coin_toss'),
                            ),
                          ),
                        ],
                      ),
                      2,
                    ),
                  ),
                ),

                // 4. Quick Actions (index 3)
                SliverToBoxAdapter(
                  child: wrapStagger(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFEAF1EB)
                                  : PremiumDesignTokens.textStrong,
                            ),
                          ),
                          PressableScale(
                            onTap: () => context.go('/groups'),
                            child: const Row(
                              children: [
                                Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: PremiumDesignTokens.textMuted,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: PremiumDesignTokens.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    3,
                  ),
                ),

                // 4 Pastel Action Buttons Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: wrapStagger(
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.shuffle_rounded,
                              label: 'Shuffle names',
                              backgroundColor: PremiumDesignTokens.green100,
                              backgroundGradient: const LinearGradient(
                                colors: [
                                  PremiumDesignTokens.green100,
                                  PremiumDesignTokens.green50,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              iconTileGradient:
                                  PremiumDesignTokens.gradPrimary,
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
                              backgroundColor: PremiumDesignTokens.peach100,
                              backgroundGradient: const LinearGradient(
                                colors: [
                                  PremiumDesignTokens.peach100,
                                  PremiumDesignTokens.peach50,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              iconTileGradient:
                                  PremiumDesignTokens.gradOrange,
                              onTap: () => context.go('/coin_toss'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.group_add_rounded,
                              label: 'Create Group',
                              backgroundColor: PremiumDesignTokens.teal100,
                              backgroundGradient: const LinearGradient(
                                colors: [
                                  PremiumDesignTokens.teal100,
                                  PremiumDesignTokens.teal50,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              iconTileGradient: PremiumDesignTokens.gradTeal,
                              onTap: () => context.go('/groups'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.history_rounded,
                              label: 'View History',
                              backgroundColor: PremiumDesignTokens.purple100,
                              backgroundGradient: const LinearGradient(
                                colors: [
                                  PremiumDesignTokens.purple100,
                                  PremiumDesignTokens.purple50,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              iconTileGradient:
                                  PremiumDesignTokens.gradPurple,
                              onTap: () => context.go('/history'),
                            ),
                          ),
                        ],
                      ),
                      3,
                    ),
                  ),
                ),

                // 5. Stats Strip (index 4)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  sliver: SliverToBoxAdapter(
                    child: wrapStagger(
                      StatsStrip(
                        totalNames: totalNames,
                        totalGroups: totalGroups,
                        totalShuffles: totalShuffles,
                        totalCoinTosses: totalCoinTosses,
                      ),
                      4,
                    ),
                  ),
                ),

                // 6. "Your Groups" Section Header (index 5)
                SliverToBoxAdapter(
                  child: wrapStagger(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: PremiumDesignTokens.green100,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.groups_rounded,
                                size: 18,
                                color: PremiumDesignTokens.green700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Your Groups',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFEAF1EB)
                                  : PremiumDesignTokens.textStrong,
                            ),
                          ),
                          const Spacer(),
                          PressableScale(
                            onTap: () => context.go('/groups'),
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: PremiumDesignTokens.gradPrimary,
                                borderRadius: BorderRadius.circular(
                                  PremiumDesignTokens.rPill,
                                ),
                                boxShadow: PremiumDesignTokens.shadowButton,
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'New Group',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    5,
                  ),
                ),

                // Horizontal Groups Cards List (index 5)
                SliverToBoxAdapter(
                  child: wrapStagger(
                    SizedBox(
                      height: 82,
                      child: groups.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: EmptyGroupCard(
                                onTap: () => context.go('/groups'),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: groups.length.clamp(0, 8),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final g = groups[index];
                                final icon = _getGroupIcon(g.name);
                                final iconTileBg = _getGroupIconBg(index, isDark);
                                final iconColor = _getGroupIconColor(index);

                                return GroupCard(
                                  name: g.name,
                                  memberCount: g.memberCount,
                                  icon: icon,
                                  iconTileBg: iconTileBg,
                                  iconColor: iconColor,
                                  onTap: () => context.push('/shuffle/${g.id}'),
                                  onMenuTap: () =>
                                      context.push('/group/${g.id}'),
                                );
                              },
                            ),
                    ),
                    5,
                  ),
                ),

                // Bottom padding = nav height (64) + 24px = 88px so content never clips behind floating nav
                const SliverPadding(padding: EdgeInsets.only(bottom: 92)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getGroupIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cricket') || lower.contains('sport')) {
      return Icons.sports_cricket_rounded;
    }
    if (lower.contains('class') || lower.contains('school')) {
      return Icons.school_rounded; // GraduationCap
    }
    if (lower.contains('game')) {
      return Icons.sports_esports_rounded; // Gamepad2
    }
    return Icons.groups_rounded; // Users
  }

  static Color _getGroupIconBg(int index, bool isDark) {
    if (isDark) return const Color(0xFF263327);
    const bgs = [
      PremiumDesignTokens.green100,
      PremiumDesignTokens.peach100,
      PremiumDesignTokens.teal100,
      PremiumDesignTokens.purple100,
    ];
    return bgs[index % bgs.length];
  }

  static Color _getGroupIconColor(int index) {
    const colors = [
      PremiumDesignTokens.green700,
      PremiumDesignTokens.orange500,
      PremiumDesignTokens.teal600,
      PremiumDesignTokens.purple600,
    ];
    return colors[index % colors.length];
  }
}
