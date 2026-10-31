import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../providers/providers.dart';

/// Faithful replication of the Shuffle Master Home Screen.
/// Extracted directly from reference image:
/// - Soft warm cream canvas
/// - "Shuffle, Pick and Decide" Hero banner with floating 3D cards
/// - Name Shuffle & Coin Toss feature cards
/// - Quick Actions & Stats pills
/// - Your Groups horizontal cards
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Header Area ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    // Brand Icon Squircle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E3A2B),
                            Color(0xFF2C553C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x181E3A2B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shuffle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Brand Title & Tagline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Shuffle ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: -0.4,
                                color: theme.colorScheme.onSurface,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Master',
                                  style: TextStyle(
                                    color: PremiumDesignTokens.mossPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Randomize anything. Decide instantly.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // User Profile Button
                    PressableScale(
                      onTap: () => context.go('/settings'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF232D25)
                              : PremiumDesignTokens.warmBeige,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF354437)
                                : const Color(0xFFEADBCA),
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: isDark
                              ? const Color(0xFFBACDBF)
                              : PremiumDesignTokens.mossDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Big Hero Banner: "Shuffle, Pick and Decide" ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [
                              Color(0xFF263327),
                              Color(0xFF1E2620),
                            ]
                          : const [
                              Color(0xFFFBF4EA),
                              Color(0xFFF1E6D4),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF354437)
                          : const Color(0xFFE9DEC8),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C2E4634),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pill Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF362C1E)
                                  : PremiumDesignTokens.softPeach,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🚀', style: TextStyle(fontSize: 11)),
                                SizedBox(width: 5),
                                Text(
                                  'MAKE DECISIONS EASIER',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF8C5325),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Large Title
                          SizedBox(
                            width: 190,
                            child: Text(
                              'Shuffle,\nPick and\nDecide',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 25,
                                height: 1.15,
                                letterSpacing: -0.6,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          SizedBox(
                            width: 180,
                            child: Text(
                              'Create groups, shuffle names, toss a coin and make fair decisions in seconds.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // "Get Started ->" Button
                          PressableScale(
                            onTap: () {
                              if (groups.isNotEmpty) {
                                context.push('/shuffle/${groups.first.id}');
                              } else {
                                context.push('/shuffle/cricket-6');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: PremiumDesignTokens.mossDark,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x301E3A2B),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 3D Card Deck Illustration on the right
                      Positioned(
                        right: 0,
                        bottom: 0,
                        top: 10,
                        child: _buildHeroCardsIllustration(isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 2 Main Feature Cards (Name Shuffle & Coin Toss) ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    // Card 1: Name Shuffle
                    Expanded(
                      child: _FeatureTile(
                        title: 'Name Shuffle',
                        description:
                            'Randomize a list of names using pure Fisher-Yates algorithm.',
                        icon: Icons.shuffle_rounded,
                        badgeText: 'Fair & Instant',
                        badgeIcon: Icons.verified_user_outlined,
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
                      child: _FeatureTile(
                        title: 'Coin Toss',
                        description:
                            'Make a quick 50/50 heads-or-tails decision with 3D animation.',
                        icon: Icons.monetization_on_outlined,
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

            // ── Quick Actions Section with "See All ->" ──
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

            // 4 Pastel Action Buttons
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
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
                      child: _QuickActionButton(
                        icon: Icons.monetization_on_outlined,
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
                      child: _QuickActionButton(
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
                      child: _QuickActionButton(
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

            // ── Stats Summary Pills ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
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
                      child: _SummaryPill(
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
                      child: _SummaryPill(
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
                      child: _SummaryPill(
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

            // ── "Your Groups" Section ──
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
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: groups.length.clamp(0, 5),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final g = groups[index];
                    final icon = _getGroupIcon(g.name);
                    final iconColor = _getGroupIconColor(index);

                    return PressableScale(
                      onTap: () => context.push('/shuffle/${g.id}'),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF222B24)
                              : PremiumDesignTokens.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334337)
                                : PremiumDesignTokens.hairline,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 16,
                                    color: iconColor,
                                  ),
                                ),
                                Icon(
                                  Icons.more_vert_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              g.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${g.memberCount} names',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
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

  Widget _buildHeroCardsIllustration(bool isDark) {
    return SizedBox(
      width: 140,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Green container box
          Positioned(
            bottom: 4,
            child: Container(
              width: 115,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2C553C),
                    Color(0xFF1E3A2B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x281E3A2B),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          // Floating mini cards
          Positioned(
            top: 10,
            left: 8,
            child: _buildMiniNameCard('Aarav', const Color(0xFFFBE4D2)),
          ),
          Positioned(
            top: 22,
            right: 4,
            child: _buildMiniNameCard('Priya', const Color(0xFFFBF4EA)),
          ),
          Positioned(
            top: 48,
            left: 14,
            child: _buildMiniNameCard('Rahul', const Color(0xFFE5EDE3)),
          ),
          Positioned(
            top: 58,
            right: 12,
            child: _buildMiniNameCard('Neha', const Color(0xFFF5E6C8)),
          ),
        ],
      ),
    );
  }

  static Widget _buildMiniNameCard(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF233629),
        ),
      ),
    );
  }
}

/// Feature Tile for Name Shuffle and Coin Toss
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.badgeIcon,
    required this.backgroundColor,
    required this.iconBoxColor,
    this.floatingPills,
    this.hasCoinGraphic = false,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final IconData badgeIcon;
  final Color backgroundColor;
  final Color iconBoxColor;
  final List<String>? floatingPills;
  final bool hasCoinGraphic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: PremiumDesignTokens.hairline.withValues(alpha: 0.6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon Box + Circular Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: PremiumDesignTokens.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                height: 1.3,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Graphic element: Pills or Coin
            if (floatingPills != null)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: floatingPills!.map((p) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: PremiumDesignTokens.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              )
            else if (hasCoinGraphic)
              Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF0BD4D),
                        Color(0xFFD68A27),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x30D68A27),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Badge Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 12, color: iconBoxColor),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: iconBoxColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Action icon button
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary Pill
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String count;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
