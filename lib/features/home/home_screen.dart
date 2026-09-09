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

    final totalNames =
        groups.fold<int>(0, (sum, g) => sum + g.memberCount);
    final totalGroups = groups.length;
    final totalShuffles = history.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Row(
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
                    Icons.shuffle,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Shuffle Master'),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Randomize your list instantly',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person_outline,
                      label: 'Names',
                      value: '$totalNames',
                      color: theme.colorScheme.primary,
                      delay: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.group_outlined,
                      label: 'Groups',
                      value: '$totalGroups',
                      color: theme.colorScheme.tertiary,
                      delay: 200,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history_outlined,
                      label: 'Shuffles',
                      value: '$totalShuffles',
                      color: theme.colorScheme.secondary,
                      delay: 300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Quick Shuffle',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),
          if (groups.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shuffle_outlined,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 16),
                      Text(
                        'No Groups Yet',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a group to start shuffling names!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push('/groups'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Group'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _GroupQuickCard(
                    groupName: group.name,
                    memberCount: group.memberCount,
                    hasMembers: group.memberCount >= 2,
                    delay: 400 + (index * 100),
                    onTap: () {
                      if (group.memberCount < 2) {
                        context.push('/group/${group.id}');
                      } else {
                        context.push('/shuffle/${group.id}');
                      }
                    },
                  );
                },
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/groups'),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      )
          .animate()
          .fadeIn(delay: 500.ms)
          .slideY(begin: 0.3, end: 0),
    );
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.2, end: 0);
  }
}

class _GroupQuickCard extends StatelessWidget {
  const _GroupQuickCard({
    required this.groupName,
    required this.memberCount,
    required this.hasMembers,
    required this.delay,
    required this.onTap,
  });

  final String groupName;
  final int memberCount;
  final bool hasMembers;
  final int delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasMembers ? Icons.shuffle : Icons.group,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                hasMembers
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.person_add_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.1, end: 0);
  }
}
