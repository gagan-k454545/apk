import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';

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
  final Random _random = Random.secure();

  ShuffleResult shuffle(Group group, {List<String>? previousOrder}) {
    if (group.members.isEmpty) {
      return ShuffleResult(
        groupId: group.id,
        groupName: group.name,
        shuffledOrder: [],
      );
    }

    final names = group.members.map((m) => m.name).toList();
    if (names.length == 1) {
      return ShuffleResult(
        groupId: group.id,
        groupName: group.name,
        shuffledOrder: List<String>.from(names),
      );
    }

    List<String> shuffled = _fisherYatesShuffle(names);

    // Reroll only if the new permutation is 100% identical to the previous permutation
    if (previousOrder != null && previousOrder.length == shuffled.length && names.length > 1) {
      final listEquals = const ListEquality<String>().equals;
      int attempts = 0;
      while (listEquals(shuffled, previousOrder) && attempts < 25) {
        shuffled = _fisherYatesShuffle(names);
        attempts++;
      }
    }

    return ShuffleResult(
      groupId: group.id,
      groupName: group.name,
      shuffledOrder: List<String>.unmodifiable(shuffled),
    );
  }

  List<String> _fisherYatesShuffle(List<String> input) {
    final list = List<String>.from(input);
    for (var i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list;
  }
}
