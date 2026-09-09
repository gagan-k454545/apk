import 'dart:math';
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
  ShuffleResult shuffle(Group group) {
    if (group.members.isEmpty) {
      return ShuffleResult(
        groupId: group.id,
        groupName: group.name,
        shuffledOrder: [],
      );
    }

    final names = group.members.map((m) => m.name).toList();
    final shuffled = _fairShuffle(names);

    return ShuffleResult(
      groupId: group.id,
      groupName: group.name,
      shuffledOrder: shuffled,
    );
  }

  List<String> _fairShuffle(List<String> names) {
    final list = List<String>.from(names);
    final random = Random.secure();

    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }

    return list;
  }
}
