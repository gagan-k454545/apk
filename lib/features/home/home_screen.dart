import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../providers/providers.dart';
import 'widgets/app_header.dart';
import 'widgets/coin_toss_feature_card.dart';
import 'widgets/group_card.dart';
import 'widgets/hero_decision_card.dart';
import 'widgets/name_shuffle_feature_card.dart';
import 'widgets/quick_action_tile.dart';
import 'widgets/stat_tile.dart';

/// Pixel-faithful replication of the Shuffle Master Home Screen matching the 3-Level Surface Hierarchy:
/// - Level 0: Warm sand page background (--bg-app #F1E8DA) with faint mint radial glow at top-left (<= 0.35 opacity).
///   All washing-out peach glow gradients & blurred smudge blobs removed.
/// - Level 1: Cards start near-white at top (linear-gradient 160deg #FFFFFF to pastel tint),
///   1px border rgba(27,67,50,0.12), two-layer shadow [0 1px 2px, 0 10px 28px].
/// - Level 2: Inner elements (solid white chips with border & shadow, solid tinted arrow buttons).
/// - Bottom Nav: Near-opaque with bottom fade (transparent to #F1E8DA, 40px) above it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final totalBottomPadding = 64.0 + 18.0 + bottomInset + 24.0;

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

    Widget buildStaggeredAction(Widget child, int index) {
      if (reduceMotion) return child;
      return child
          .animate()
          .fadeIn(
            duration: const Duration(milliseconds: 460),
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            delay: Duration(milliseconds: 80 * index),
          )
          .slideX(
            begin: -0.45,
            end: 0.0,
            duration: const Duration(milliseconds: 520),
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            delay: Duration(milliseconds: 80 * index),
          )
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 520),
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            delay: Duration(milliseconds: 80 * index),
          );
    }

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp, // Level 0: #E4DACA
      body: SafeArea(
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
                          // Card A: Name Shuffle (High-Fidelity 3D Feature Card)
                          Expanded(
                            child: NameShuffleFeatureCard(
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

                          // Card B: Coin Toss (High-Fidelity 3D Feature Card matching Name Shuffle)
                          Expanded(
                            child: CoinTossFeatureCard(
                              onTap: () => context.push('/coin_toss_screen'),
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
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                        ],
                      ),
                    ),
                    3,
                  ),
                ),

                // 4 Pastel Action Buttons Grid (Staggered left-to-right cinematic entry)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: buildStaggeredAction(
                            QuickActionTile(
                              icon: Icons.shuffle_rounded,
                              label: 'Shuffle names',
                              backgroundColor: PremiumDesignTokens.surfaceSoft,
                              backgroundGradient:
                                  PremiumDesignTokens.gradNeutralCard,
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
                            0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildStaggeredAction(
                            QuickActionTile(
                              icon: Icons.monetization_on_rounded,
                              label: 'Toss Coin',
                              backgroundColor: PremiumDesignTokens.surfaceSoft,
                              backgroundGradient:
                                  PremiumDesignTokens.gradNeutralCard,
                              iconTileGradient:
                                  PremiumDesignTokens.gradOrange,
                              onTap: () => context.push('/coin_toss_screen'),
                            ),
                            1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildStaggeredAction(
                            QuickActionTile(
                              icon: Icons.group_add_rounded,
                              label: 'Create Group',
                              backgroundColor: PremiumDesignTokens.surfaceSoft,
                              backgroundGradient:
                                  PremiumDesignTokens.gradNeutralCard,
                              iconTileGradient: PremiumDesignTokens.gradTeal,
                              onTap: () => context.go('/groups'),
                            ),
                            2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildStaggeredAction(
                            QuickActionTile(
                              icon: Icons.history_rounded,
                              label: 'View History',
                              backgroundColor: PremiumDesignTokens.surfaceSoft,
                              backgroundGradient:
                                  PremiumDesignTokens.gradNeutralCard,
                              iconTileGradient:
                                  PremiumDesignTokens.gradPurple,
                              onTap: () => context.go('/history'),
                            ),
                            3,
                          ),
                        ),
                      ],
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
                            decoration: BoxDecoration(
                              color: PremiumDesignTokens.green100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PremiumDesignTokens.innerBorder,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.groups_rounded,
                                size: 18,
                                color: PremiumDesignTokens.green700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your Groups',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
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
                      height: 122,
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
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              clipBehavior: Clip.none,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: groups.length.clamp(0, 8),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final g = groups[index];
                                final icon = _getGroupIcon(g.name);
                                final iconTileBg = _getGroupIconBg(index);
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

                // Bottom padding = nav height (64) + FAB overhang (18) + safe-area + 24px
                SliverPadding(
                  padding: EdgeInsets.only(bottom: totalBottomPadding),
                ),
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
      return Icons.school_rounded; // GraduationCap
    }
    if (lower.contains('game')) {
      return Icons.sports_esports_rounded; // Gamepad2
    }
    return Icons.groups_rounded; // Users
  }

  static Color _getGroupIconBg(int index) {
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
