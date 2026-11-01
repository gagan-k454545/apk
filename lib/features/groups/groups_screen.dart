import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Groups Screen designed following Apple Human Interface Guidelines
/// and Emil Kowalski's Design Engineering principles:
/// - Inset grouped hierarchy with 3-level surfaces
/// - Minimum 44x44 pt touch targets for all interactive controls
/// - Direct group deletion from cards and rename/edit sheets
/// - Alphabetical A-Z sorting toggle
/// - iOS-style rounded bottom sheets with useRootNavigator to avoid bottom nav overlay
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortByAlphabetical = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final filteredGroups = _searchQuery.isEmpty
        ? List<Group>.from(groups)
        : groups
            .where((g) =>
                g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (_sortByAlphabetical) {
      filteredGroups.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS-style Large Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Groups',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${groups.length} ${groups.length == 1 ? 'group' : 'groups'} available to shuffle',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: PremiumDesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // iOS New Group Circular Action Button (44x44 touch target)
                    PressableScale(
                      onTap: () => _showCreateSheet(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: PremiumDesignTokens.gradPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x331B4332),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Inset Search Field & A-Z Sort Toggle
            if (groups.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PremiumDesignTokens.innerBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: PremiumDesignTokens.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val.trim()),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: PremiumDesignTokens.textStrong,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search groups...',
                                    hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: PremiumDesignTokens.textMuted,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      Icons.cancel,
                                      size: 18,
                                      color: PremiumDesignTokens.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Alphabetical Sort Button
                      PressableScale(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _sortByAlphabetical = !_sortByAlphabetical;
                          });
                        },
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _sortByAlphabetical
                                ? PremiumDesignTokens.forestDark
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _sortByAlphabetical
                                  ? PremiumDesignTokens.forestDark
                                  : PremiumDesignTokens.innerBorder,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x101B4332),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort_by_alpha_rounded,
                                size: 18,
                                color: _sortByAlphabetical
                                    ? Colors.white
                                    : PremiumDesignTokens.forestDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'A-Z',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _sortByAlphabetical
                                      ? Colors.white
                                      : PremiumDesignTokens.forestDark,
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

            // Groups List / Empty State
            if (groups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PremiumDesignTokens.cardBorder,
                            ),
                            boxShadow: PremiumDesignTokens.cardShadow,
                          ),
                          child: const Icon(
                            Icons.groups_outlined,
                            size: 40,
                            color: PremiumDesignTokens.forestDark,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No Groups Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: PremiumDesignTokens.textStrong,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a group with friends, colleagues, or teams to randomize quickly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: PremiumDesignTokens.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PressableScale(
                          onTap: () => _showCreateSheet(context),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: PremiumDesignTokens.gradPrimary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x331B4332),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Create First Group',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
              )
            else if (filteredGroups.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No groups match your search',
                    style: TextStyle(
                      fontSize: 15,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(group.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) =>
                            _confirmDelete(context, group.name),
                        onDismissed: (direction) {
                          ref
                              .read(groupsProvider.notifier)
                              .deleteGroup(group.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${group.name}"'),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  ref
                                      .read(groupsProvider.notifier)
                                      .addGroup(group.name);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 6),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: _IOSGroupCard(
                          group: group,
                          onTap: () => context.push('/group/${group.id}'),
                          onShuffle: () =>
                              context.push('/shuffle/${group.id}'),
                          onEdit: () => _showEditSheet(
                              context, group.id, group.name),
                          onDelete: () => _deleteGroupWithPrompt(
                              context, group.id, group.name),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Safe Clearance for Bottom Nav + Home Indicator
            SliverPadding(
              padding: EdgeInsets.only(bottom: 130 + bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGroupWithPrompt(
      BuildContext context, String groupId, String name) async {
    final confirmed = await _confirmDelete(context, name);
    if (confirmed == true && mounted) {
      await ref.read(groupsProvider.notifier).deleteGroup(groupId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "$name"'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(groupsProvider.notifier).addGroup(name);
              },
            ),
          ),
        );
      }
    }
  }

  void _showCreateSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x261B4332),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // iOS Handle bar
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(sheetContext),
                  child: const SizedBox(
                    width: 60,
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: PremiumDesignTokens.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'New Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.textStrong,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      ref.read(groupsProvider.notifier).addGroup(name);
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const SizedBox(
                    width: 60,
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          color: PremiumDesignTokens.forestDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1E8DA).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PremiumDesignTokens.innerBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 16,
                  color: PremiumDesignTokens.textStrong,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. Friends, Team Alpha, Family',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: PremiumDesignTokens.textMuted,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  final name = val.trim();
                  if (name.isNotEmpty) {
                    HapticFeedback.selectionClick();
                    ref.read(groupsProvider.notifier).addGroup(name);
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, String groupId, String currentName) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController(text: currentName);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x261B4332),
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: const SizedBox(
                      width: 60,
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: PremiumDesignTokens.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Rename Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(groupsProvider.notifier)
                            .renameGroup(groupId, name);
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: const SizedBox(
                      width: 60,
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            color: PremiumDesignTokens.forestDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8DA).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PremiumDesignTokens.innerBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setSheetState(() {}),
                        style: const TextStyle(
                          fontSize: 16,
                          color: PremiumDesignTokens.textStrong,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Group name',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          final name = val.trim();
                          if (name.isNotEmpty) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(groupsProvider.notifier)
                                .renameGroup(groupId, name);
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ),
                    if (controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.clear();
                          setSheetState(() {});
                        },
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: PremiumDesignTokens.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Option to delete group right inside edit/rename sheet
              PressableScale(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _deleteGroupWithPrompt(context, groupId, currentName);
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF8B4B4)),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: Color(0xFFE53935),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Delete Group',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: PremiumDesignTokens.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Delete Group?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All member names in "$name" will be permanently removed.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                  const Divider(height: 24),
                  PressableScale(
                    onTap: () => Navigator.pop(sheetContext, true),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Delete Group',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PressableScale(
              onTap: () => Navigator.pop(sheetContext, false),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: PremiumDesignTokens.cardShadow,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IOSGroupCard extends StatelessWidget {
  const _IOSGroupCard({
    required this.group,
    required this.onTap,
    required this.onShuffle,
    required this.onEdit,
    required this.onDelete,
  });

  final Group group;
  final VoidCallback onTap;
  final VoidCallback onShuffle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = group.name.trim().isNotEmpty
        ? group.name.trim().substring(0, 1).toUpperCase()
        : 'G';

    return PressableScale(
      targetScale: 0.98,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFBF7F0),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Left squircle avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PremiumDesignTokens.innerBorder),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Group details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EEDC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0x1F1B4332),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '${group.memberCount} ${group.memberCount == 1 ? 'name' : 'names'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: PremiumDesignTokens.forestDark,
                          ),
                        ),
                      ),
                      if (group.favorites.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFD69A2D),
                        ),
                        Text(
                          ' ${group.favorites.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD69A2D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Edit button (38x44 touch target)
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: PremiumDesignTokens.textMuted,
                ),
              ),
            ),

            // Delete button (38x44 touch target)
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 44,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: Color(0xFFC53030),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Quick Shuffle Button
            if (group.memberCount >= 2) ...[
              PressableScale(
                onTap: onShuffle,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: PremiumDesignTokens.gradPrimary,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x261B4332),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shuffle_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Shuffle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: PremiumDesignTokens.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
