import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Group Detail Screen designed following Apple Human Interface Guidelines:
/// - iOS Large Navigation Bar with prominent back button (44x44pt)
/// - Sort names alphabetically A-Z action button & toolbar
/// - Direct group deletion option with modal confirmation
/// - Inset Grouped members list with rank indicators
/// - Favorite toggle with spring animation and haptic feedback
/// - Tactile "SHUFFLE NOW" button pinned at bottom with blur and safe area
/// - iOS style modal bottom sheets for adding and editing members with useRootNavigator
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(name: 'Unknown'),
    );
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final filteredMembers = _searchQuery.isEmpty
        ? group.members
        : group.members
            .where((m) =>
                m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Navigation Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Back button (44x44pt touch area)
                    GestureDetector(
                      onTap: () => context.pop(),
                      behavior: HitTestBehavior.opaque,
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
                              color: Color(0x141B4332),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: PremiumDesignTokens.forestDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: PremiumDesignTokens.textStrong,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            '${group.memberCount} ${group.memberCount == 1 ? 'member' : 'members'} · Drag to reorder',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: PremiumDesignTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Action: Sort Names A-Z
                    if (group.members.isNotEmpty) ...[
                      Tooltip(
                        message: 'Sort names A-Z',
                        child: GestureDetector(
                          onTap: () => _sortAlphabetically(context, group),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PremiumDesignTokens.innerBorder,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x141B4332),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sort_by_alpha_rounded,
                              size: 19,
                              color: PremiumDesignTokens.forestDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Quick Action: Delete Group
                    Tooltip(
                      message: 'Delete Group',
                      child: GestureDetector(
                        onTap: () => _confirmDeleteGroup(context, group),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF8B4B4),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x141B4332),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick Action: Add names
                    Tooltip(
                      message: 'Add Name',
                      child: GestureDetector(
                        onTap: () => _showAddNameSheet(context, group),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PremiumDesignTokens.innerBorder,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x141B4332),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 19,
                            color: PremiumDesignTokens.forestDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Inset Search Field
            if (group.members.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
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
                              hintText: 'Search members...',
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
                              padding: EdgeInsets.symmetric(horizontal: 10),
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
              ),

            // Members Toolbar: Count + Quick Sort Button
            if (group.members.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 2, 22, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredMembers.length} ${filteredMembers.length == 1 ? 'name' : 'names'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PremiumDesignTokens.textMuted,
                        ),
                      ),
                      PressableScale(
                        onTap: () => _sortAlphabetically(context, group),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sort_by_alpha_rounded,
                                size: 14,
                                color: PremiumDesignTokens.forestDark,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Sort A-Z',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: PremiumDesignTokens.forestDark,
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

            // Members List or Empty State
            if (group.members.isEmpty)
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
                            Icons.person_add_outlined,
                            size: 38,
                            color: PremiumDesignTokens.forestDark,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No Names in Group',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: PremiumDesignTokens.textStrong,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add at least 2 members to enable the Fisher-Yates smart shuffle.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: PremiumDesignTokens.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PressableScale(
                          onTap: () => _showAddNameSheet(context, group),
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
                                  'Add First Name',
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
            else if (filteredMembers.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No members found',
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
                sliver: SliverReorderableList(
                  itemCount: filteredMembers.length,
                  // ignore: deprecated_member_use
                  onReorder: (oldIndex, newIndex) {
                    if (_searchQuery.isNotEmpty) return;
                    HapticFeedback.selectionClick();
                    ref.read(groupsProvider.notifier).reorderMembers(
                          group.id,
                          oldIndex,
                          newIndex,
                        );
                  },
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    final globalIndex = group.members.indexOf(member);

                    return Padding(
                      key: ValueKey(member.id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IOSMemberCard(
                        member: member,
                        index: globalIndex,
                        onTap: () => _showEditSheet(
                            context, group.id, member.id, member.name),
                        onFavorite: () {
                          HapticFeedback.lightImpact();
                          ref.read(groupsProvider.notifier).toggleFavorite(
                                group.id,
                                member.id,
                              );
                        },
                        onDelete: () => _confirmRemove(
                          context,
                          group.id,
                          member.id,
                          member.name,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom Clearance for pinned button
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: group.memberCount >= 2 ? 100 + bottomInset : 40,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: group.memberCount >= 2
          ? Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(
                    color: Color(0x1F1B4332),
                    width: 0.6,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A1B4332),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: PressableScale(
                targetScale: 0.98,
                onTap: () => context.push('/shuffle/${group.id}'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: PremiumDesignTokens.gradPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x331B4332),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle_rounded,
                          size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'SHUFFLE NOW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _sortAlphabetically(BuildContext context, Group group) async {
    unawaited(HapticFeedback.mediumImpact());
    await ref
        .read(groupsProvider.notifier)
        .sortMembersAlphabetically(widget.groupId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Names sorted alphabetically (A-Z) in "${group.name}"'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
    }
  }

  Future<void> _confirmDeleteGroup(BuildContext context, Group group) async {
    unawaited(HapticFeedback.lightImpact());
    final confirmed = await showModalBottomSheet<bool>(
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
                    'All member names in "${group.name}" will be permanently removed.',
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

    if (confirmed == true && mounted) {
      await ref.read(groupsProvider.notifier).deleteGroup(group.id);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${group.name}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddNameSheet(BuildContext context, Group group) {
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
                  'Add Member',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.textStrong,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      unawaited(HapticFeedback.selectionClick());
                      await ref
                          .read(groupsProvider.notifier)
                          .addMember(widget.groupId, name);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    }
                  },
                  child: const SizedBox(
                    width: 60,
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Add',
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
            const SizedBox(height: 14),
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
                  hintText: 'Member full name',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: PremiumDesignTokens.textMuted,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) async {
                  final name = val.trim();
                  if (name.isNotEmpty) {
                    unawaited(HapticFeedback.selectionClick());
                    await ref
                        .read(groupsProvider.notifier)
                        .addMember(widget.groupId, name);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
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

  void _showEditSheet(BuildContext context, String groupId, String memberId,
      String currentName) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController(text: currentName);

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
                  'Edit Member',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.textStrong,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      unawaited(HapticFeedback.selectionClick());
                      await ref
                          .read(groupsProvider.notifier)
                          .editMember(groupId, memberId, name);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
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
            const SizedBox(height: 14),
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
                  border: InputBorder.none,
                ),
                onSubmitted: (val) async {
                  final name = val.trim();
                  if (name.isNotEmpty) {
                    unawaited(HapticFeedback.selectionClick());
                    await ref
                        .read(groupsProvider.notifier)
                        .editMember(groupId, memberId, name);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
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

  void _confirmRemove(
      BuildContext context, String groupId, String memberId, String name) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
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
                  Text(
                    'Remove "$name"?',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This member will be removed from future randomized orders for this group.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                  const Divider(height: 24),
                  PressableScale(
                    onTap: () async {
                      unawaited(HapticFeedback.selectionClick());
                      await ref
                          .read(groupsProvider.notifier)
                          .removeMember(groupId, memberId);
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Remove Member',
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
              onTap: () => Navigator.pop(sheetContext),
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

class _IOSMemberCard extends StatelessWidget {
  const _IOSMemberCard({
    required this.member,
    required this.index,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  final NameEntry member;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumDesignTokens.cardBorder),
        boxShadow: PremiumDesignTokens.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Index Badge Squircle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0x1F1B4332),
                width: 0.6,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: PremiumDesignTokens.forestDark,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name Text
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PremiumDesignTokens.textStrong,
              ),
            ),
          ),

          // Favorite Star (40x44pt hit area)
          GestureDetector(
            onTap: onFavorite,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                member.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 22,
                color: member.isFavorite
                    ? const Color(0xFFD69A2D)
                    : PremiumDesignTokens.textMuted,
              ),
            ),
          ),

          // Edit Button (38x44pt hit area)
          GestureDetector(
            onTap: onTap,
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

          // Delete Member Button (38x44pt hit area)
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

          // Reorder Drag Handle (34x44pt hit area)
          ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 34,
              height: 44,
              alignment: Alignment.center,
              child: const Icon(
                Icons.drag_indicator_rounded,
                size: 20,
                color: PremiumDesignTokens.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
