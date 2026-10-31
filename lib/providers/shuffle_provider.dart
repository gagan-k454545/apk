import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../core/shuffle/shuffle_engine.dart';

export '../core/shuffle/shuffle_engine.dart';

class ShuffleResult {
  ShuffleResult({
    required this.groupId,
    required this.groupName,
    required this.shuffledOrder,
  });

  final String groupId;
  final String groupName;
  final List<String> shuffledOrder;
}

final shuffleServiceProvider = Provider<ShuffleService>((ref) {
  return ShuffleService();
});

class ShuffleService {
  final ShuffleMemory _memory = ShuffleMemory.instance;

  /// Shuffles a group using the 4-layer smart shuffle algorithm:
  /// - CSPRNG source (rejection sampling, no modulo bias)
  /// - Fisher-Yates uniform permutation
  /// - Anti-pattern layer scoring against recent orders
  /// - Stable unique IDs to correctly handle duplicates and trimmed names
  ShuffleResult shuffle(Group group, {List<String>? previousOrder}) {
    if (group.members.isEmpty) {
      return ShuffleResult(
        groupId: group.id,
        groupName: group.name,
        shuffledOrder: const [],
      );
    }

    // 1. Build stable IDs and map to display names.
    // Handles duplicate names safely by giving each entry its own stable ID.
    final Map<String, String> idToName = {};
    final List<String> stableIds = [];
    for (int i = 0; i < group.members.length; i++) {
      final member = group.members[i];
      final String id = member.id.isNotEmpty
          ? member.id
          : 'entry_${group.id}_$i';
      final String trimmedName = member.name.trim();
      idToName[id] = trimmedName;
      stableIds.add(id);
    }

    // 0 or 1 names: return as is
    if (stableIds.length == 1) {
      return ShuffleResult(
        groupId: group.id,
        groupName: group.name,
        shuffledOrder: List<String>.unmodifiable([idToName[stableIds.first] ?? '']),
      );
    }

    final String listKey = _memory.getListKey(
      groupId: group.id,
      names: idToName.values.toList(),
    );

    List<List<String>> history = _memory.getRecentOrders(listKey);

    // If memory is empty but previousOrder was passed by the caller,
    // convert the previousOrder display names into stable IDs and inject
    if (history.isEmpty && previousOrder != null && previousOrder.isNotEmpty) {
      final prevIds = <String>[];
      final used = <String>{};
      for (final name in previousOrder) {
        final trimmed = name.trim();
        final matchedId = stableIds.firstWhere(
          (id) => idToName[id] == trimmed && !used.contains(id),
          orElse: () => '',
        );
        if (matchedId.isNotEmpty) {
          prevIds.add(matchedId);
          used.add(matchedId);
        }
      }
      if (prevIds.length == stableIds.length) {
        history = [prevIds];
      }
    }

    // Run smart shuffle on stable IDs
    final List<String> shuffledIds = smartShuffle(stableIds, history);

    // Persist new order into history memory
    _memory.recordOrder(listKey, shuffledIds);

    // Map stable IDs back to display names
    final List<String> shuffledNames = shuffledIds
        .map((id) => idToName[id] ?? '')
        .toList();

    return ShuffleResult(
      groupId: group.id,
      groupName: group.name,
      shuffledOrder: List<String>.unmodifiable(shuffledNames),
    );
  }

  /// Winner / "pick one" mode: shuffle-bag.
  /// Each name is picked once before any name repeats.
  /// The last winner cannot be first in the next bag.
  String pickWinner(Group group) {
    if (group.members.isEmpty) {
      throw ArgumentError('Cannot pick winner from empty group');
    }

    final Map<String, String> idToName = {};
    final List<String> stableIds = [];
    for (int i = 0; i < group.members.length; i++) {
      final member = group.members[i];
      final String id = member.id.isNotEmpty
          ? member.id
          : 'entry_${group.id}_$i';
      idToName[id] = member.name.trim();
      stableIds.add(id);
    }

    final String listKey = _memory.getListKey(
      groupId: group.id,
      names: idToName.values.toList(),
    );

    final BagState? state = _memory.getBagState(listKey);
    final PickResult result = pickFromBag(stableIds, state);

    _memory.saveBagState(listKey, result.state);

    return idToName[result.picked] ?? '';
  }

  /// Clears the shuffle memory for this group or list.
  void resetShuffleMemory(String? groupId) {
    if (groupId != null && groupId.isNotEmpty) {
      _memory.resetMemory('group_$groupId');
    } else {
      _memory.resetMemory();
    }
  }

  /// Pure Fisher-Yates shuffle helper.
  List<String> fisherYatesShuffle(List<String> input) {
    return fisherYates<String>(input);
  }
}
