import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/app_repository.dart';
import 'repository_provider.dart';

class GroupsNotifier extends StateNotifier<List<Group>> {
  GroupsNotifier(this._repository) : super(_repository.getGroups()) {
    _load();
  }

  final AppRepository _repository;

  void _load() {
    state = _repository.getGroups();
  }

  Future<void> addGroup(String name) async {
    final group = Group(name: name);
    await _repository.saveGroup(group);
    _load();
  }

  Future<void> renameGroup(String groupId, String newName) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    await _repository.saveGroup(group.copyWith(name: newName));
    _load();
  }

  Future<void> deleteGroup(String groupId) async {
    await _repository.deleteGroup(groupId);
    _load();
  }

  Future<void> addMember(String groupId, String name) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final member = NameEntry(name: name);
    final updatedMembers = List<NameEntry>.from(group.members)..add(member);
    await _repository.saveGroup(group.copyWith(members: updatedMembers));
    _load();
  }

  Future<void> addMembers(String groupId, List<String> names) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final newMembers =
        names.map((n) => NameEntry(name: n)).toList();
    final updatedMembers = List<NameEntry>.from(group.members)
      ..addAll(newMembers);
    await _repository.saveGroup(group.copyWith(members: updatedMembers));
    _load();
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final updatedMembers =
        group.members.where((m) => m.id != memberId).toList();
    await _repository.saveGroup(group.copyWith(members: updatedMembers));
    _load();
  }

  Future<void> editMember(
      String groupId, String memberId, String newName) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final updatedMembers = group.members.map((m) {
      if (m.id == memberId) return m.copyWith(name: newName);
      return m;
    }).toList();
    await _repository.saveGroup(group.copyWith(members: updatedMembers));
    _load();
  }

  Future<void> toggleFavorite(String groupId, String memberId) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final updatedMembers = group.members.map((m) {
      if (m.id == memberId) {
        return m.copyWith(isFavorite: !m.isFavorite);
      }
      return m;
    }).toList();
    await _repository.saveGroup(group.copyWith(members: updatedMembers));
    _load();
  }

  Future<void> reorderMembers(
      String groupId, int oldIndex, int newIndex) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final members = List<NameEntry>.from(group.members);
    final item = members.removeAt(oldIndex);
    members.insert(newIndex, item);
    await _repository.saveGroup(group.copyWith(members: members));
    _load();
  }

  Future<void> sortMembersAlphabetically(String groupId,
      {bool ascending = true}) async {
    final group = _repository.getGroup(groupId);
    if (group == null) return;
    final sortedMembers = List<NameEntry>.from(group.members)
      ..sort((a, b) => ascending
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    await _repository.saveGroup(group.copyWith(members: sortedMembers));
    _load();
  }

  Group? getGroupById(String id) => _repository.getGroup(id);
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  return GroupsNotifier(ref.read(repositoryProvider));
});
