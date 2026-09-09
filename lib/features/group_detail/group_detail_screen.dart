import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = ref.watch(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: 'Unknown'),
    );

    final filteredMembers = _searchQuery.isEmpty
        ? group.members
        : group.members
            .where((m) =>
                m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(group.name),
            actions: [
              if (group.memberCount >= 2)
                IconButton(
                  onPressed: () => context.push('/shuffle/${group.id}'),
                  icon: const Icon(Icons.shuffle),
                  tooltip: 'Shuffle',
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search names...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.clear, size: 20),
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (group.memberCount >= 2)
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/shuffle/${group.id}'),
                      icon: const Icon(Icons.shuffle, size: 18),
                      label: const Text('Shuffle'),
                    ),
                ],
              ),
            ),
          ),
          if (group.members.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 64,
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Names Yet',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add names to this group to start shuffling.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (filteredMembers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No results for "$_searchQuery"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverReorderableList(
                itemCount: filteredMembers.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  if (_searchQuery.isNotEmpty) return;
                  ref.read(groupsProvider.notifier).reorderMembers(
                        group.id,
                        oldIndex,
                        newIndex,
                      );
                },
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final globalIndex = group.members.indexOf(member);
                  return _NameCard(
                    key: ValueKey(member.id),
                    name: member.name,
                    isFavorite: member.isFavorite,
                    index: globalIndex,
                    onTap: () => _showEditDialog(
                      context,
                      ref,
                      group.id,
                      member.id,
                      member.name,
                    ),
                    onDelete: () => _confirmRemove(
                      context,
                      ref,
                      group.id,
                      member.id,
                      member.name,
                    ),
                    onFavorite: () {
                      ref.read(groupsProvider.notifier).toggleFavorite(
                            group.id,
                            member.id,
                          );
                    },
                  );
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${group.memberCount} ${group.memberCount == 1 ? 'name' : 'names'} in this group',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'paste',
            onPressed: () => _showBulkAddDialog(context, ref, group.id),
            child: const Icon(Icons.content_paste_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => _showAddNameDialog(context, ref, group.id),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add Name'),
          ),
        ],
      ),
    );
  }

  void _showAddNameDialog(
      BuildContext context, WidgetRef ref, String groupId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _AddNameDialog(
        controller: controller,
        groupId: groupId,
        ref: ref,
      ),
    );
  }

  void _showBulkAddDialog(
      BuildContext context, WidgetRef ref, String groupId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _BulkAddDialog(
        controller: controller,
        groupId: groupId,
        ref: ref,
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String groupId,
      String memberId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(groupsProvider.notifier)
                  .editMember(groupId, memberId, value.trim());
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(groupsProvider.notifier)
                    .editMember(groupId, memberId, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, String groupId,
      String memberId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove "$name"?'),
        content: const Text('This name will be removed from the group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(groupsProvider.notifier)
                  .removeMember(groupId, memberId);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
  });

  final String name;
  final bool isFavorite;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
      const Color(0xFF00897B),
      const Color(0xFFE65100),
      const Color(0xFF5C6BC0),
    ];
    final avatarColor = colors[index % colors.length];

    return Dismissible(
      key: ValueKey('name_$name'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Remove "$name"?'),
            content: const Text('This name will be removed from the group.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: avatarColor.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : null,
                ),
                iconSize: 22,
                tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.edit_outlined),
                iconSize: 20,
                tooltip: 'Edit',
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddNameDialog extends ConsumerStatefulWidget {
  const _AddNameDialog({
    required this.controller,
    required this.groupId,
    required this.ref,
  });

  final TextEditingController controller;
  final String groupId;
  final WidgetRef ref;

  @override
  ConsumerState<_AddNameDialog> createState() => _AddNameDialogState();
}

class _AddNameDialogState extends ConsumerState<_AddNameDialog> {
  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: ''),
    );

    return AlertDialog(
      title: const Text('Add Name'),
      content: TextField(
        controller: widget.controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Enter name',
          prefixIcon: Icon(Icons.person_outlined),
        ),
        onSubmitted: (value) => _submit(value, group),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(widget.controller.text, group),
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit(String value, Group group) {
    final name = value.trim();
    if (name.isEmpty) return;

    final isDuplicate =
        group.members.any((m) => m.name.toLowerCase() == name.toLowerCase());
    if (isDuplicate) {
      _showDuplicateDialog(context, name, group);
      return;
    }

    widget.ref.read(groupsProvider.notifier).addMember(widget.groupId, name);
    widget.controller.clear();
    Navigator.of(context).pop();
  }

  void _showDuplicateDialog(BuildContext context, String name, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Duplicate Name'),
        content: Text('"$name" already exists in this group. Add anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(groupsProvider.notifier)
                  .addMember(widget.groupId, name);
              widget.controller.clear();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }
}

class _BulkAddDialog extends ConsumerStatefulWidget {
  const _BulkAddDialog({
    required this.controller,
    required this.groupId,
    required this.ref,
  });

  final TextEditingController controller;
  final String groupId;
  final WidgetRef ref;

  @override
  ConsumerState<_BulkAddDialog> createState() => _BulkAddDialogState();
}

class _BulkAddDialogState extends ConsumerState<_BulkAddDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paste Names'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Separate names with new lines, commas, or semicolons.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller,
              autofocus: true,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'John, Alex, David\nEmma; Sophia',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add All'),
        ),
      ],
    );
  }

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    final names = text
        .split(RegExp(r'[\n,;]'))
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (names.isEmpty) return;

    ref.read(groupsProvider.notifier).addMembers(widget.groupId, names);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${names.length} ${names.length == 1 ? 'name' : 'names'} added'),
      ),
    );
  }
}
