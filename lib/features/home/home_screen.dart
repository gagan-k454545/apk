import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groups = ref.watch(groupsProvider);
    final history = ref.watch(historyProvider);
    final coinTossHistory = ref.watch(coinTossProvider);

    final totalNames = groups.fold<int>(0, (sum, g) => sum + g.memberCount);
    final totalGroups = groups.length;
    final totalShuffles = history.length;
    final totalCoinTosses = coinTossHistory.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shuffle_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Shuffle Master'),
                  ],
                ),
                Text(
                  'Randomize anything. Decide instantly.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 2 Major SaaS Feature Cards (Requirement 17)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _FeatureCard(
                    title: 'NAME SHUFFLE',
                    description:
                        'Randomize a list of names using pure Fisher-Yates algorithm.',
                    buttonText: 'Open Shuffle →',
                    icon: Icons.shuffle_rounded,
                    gradientColors: [
                      theme.colorScheme.primary,
                      const Color(0xFF4F46E5),
                    ],
                    onTap: () {
                      if (groups.isNotEmpty) {
                        context.push('/shuffle/${groups.first.id}');
                      } else {
                        context.push('/groups');
                      }
                    },
                    delay: 100,
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    title: 'COIN TOSS',
                    description:
                        'Make a quick 50/50 heads-or-tails decision with 3D animation.',
                    buttonText: 'Toss Coin →',
                    icon: Icons.monetization_on_outlined,
                    gradientColors: const [
                      Color(0xFFF59E0B),
                      Color(0xFFEC4899),
                    ],
                    onTap: () => context.go('/coin_toss'),
                    delay: 200,
                  ),
                ],
              ),
            ),
          ),

          // Quick Actions Section (Requirement 18)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (groups.isNotEmpty) {
                              context.push('/shuffle/${groups.first.id}');
                            } else {
                              context.push('/groups');
                            }
                          },
                          icon: const Icon(Icons.shuffle_rounded, size: 18),
                          label: const Text('Shuffle Names'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/coin_toss'),
                          icon: const Icon(Icons.monetization_on_outlined, size: 18),
                          label: const Text('Toss Coin'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),

          // Overview Stats
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person_outline,
                      label: 'Names',
                      value: '$totalNames',
                      color: theme.colorScheme.primary,
                      delay: 350,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.group_outlined,
                      label: 'Groups',
                      value: '$totalGroups',
                      color: theme.colorScheme.tertiary,
                      delay: 400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history_outlined,
                      label: 'Shuffles',
                      value: '$totalShuffles',
                      color: theme.colorScheme.secondary,
                      delay: 450,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.monetization_on_outlined,
                      label: 'Tosses',
                      value: '$totalCoinTosses',
                      color: const Color(0xFFF59E0B),
                      delay: 500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Groups Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Groups',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/groups'),
                    child: const Text('See All'),
                  ),
                ],
              ).animate().fadeIn(delay: 550.ms),
            ),
          ),

          // Groups List or Empty State
          if (groups.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_add_outlined,
                          size: 48,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Groups Created',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a group of names to start shuffling.',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.go('/groups'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Group'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: groups.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _GroupQuickCard(
                    groupName: group.name,
                    memberCount: group.memberCount,
                    hasMembers: group.memberCount >= 2,
                    delay: 600 + (index * 60),
                    onTapCard: () => context.push('/group/${group.id}'),
                    onShuffle: () => context.push('/shuffle/${group.id}'),
                  );
                },
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/groups'),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      )
          .animate()
          .fadeIn(delay: 650.ms)
          .slideY(begin: 0.3, end: 0),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    required this.delay,
  });

  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withValues(alpha: 0.12),
                gradientColors[1].withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          buttonText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: gradientColors[0],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0);
  }
}

class _GroupQuickCard extends StatelessWidget {
  const _GroupQuickCard({
    required this.groupName,
    required this.memberCount,
    required this.hasMembers,
    required this.delay,
    required this.onTapCard,
    required this.onShuffle,
  });

  final String groupName;
  final int memberCount;
  final bool hasMembers;
  final int delay;
  final VoidCallback onTapCard;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (hasMembers)
                FilledButton.icon(
                  onPressed: onShuffle,
                  icon: const Icon(Icons.shuffle, size: 16),
                  label: const Text('Shuffle'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: onTapCard,
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Add Names'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.05, end: 0);
  }
}
