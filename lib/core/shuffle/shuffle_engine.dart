import 'dart:math';

/// Cryptographically secure random number generator instance.
/// Throws [StateError] if CSPRNG is unavailable on the platform.
final Random _secureRandom = _initSecureRandom();

Random _initSecureRandom() {
  try {
    return Random.secure();
  } catch (e) {
    throw StateError(
      'CSPRNG is unavailable: Cryptographically secure random number generator '
      '(crypto.getRandomValues / Random.secure) could not be initialized: $e',
    );
  }
}

/// 32-bit unsigned integer maximum value: 2^32 = 4,294,967,296.
const int maxU32 = 0x100000000;

/// Returns an unbiased random integer in the range `[0, max)` using
/// rejection sampling on 32-bit cryptographically secure random integers.
/// Eliminates modulo bias completely.
int randomInt(int max) {
  if (max <= 0) {
    throw ArgumentError('max must be a positive integer, got $max');
  }

  // Calculate the rejection sampling threshold
  final int limit = maxU32 - (maxU32 % max);
  int sample;
  do {
    sample = _secureRandom.nextInt(maxU32);
  } while (sample >= limit);

  return sample % max;
}

/// Fisher-Yates (Durstenfeld) shuffle: the only correct uniform permutation algorithm.
/// Never mutates the input list. Returns a new uniformly shuffled list.
List<T> fisherYates<T>(List<T> items) {
  final List<T> a = List<T>.from(items);
  for (int i = a.length - 1; i > 0; i--) {
    final int j = randomInt(i + 1);
    final T temp = a[i];
    a[i] = a[j];
    a[j] = temp;
  }
  return a;
}

/// Returns true if two lists have the identical element order.
bool sameOrder<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Returns true if two lists contain the identical multiset of strings.
bool sameSet(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  final sortedA = List<String>.from(a)..sort();
  final sortedB = List<String>.from(b)..sort();
  return sameOrder(sortedA, sortedB);
}

/// Computes the similarity penalty between a candidate permutation [cand]
/// and a previous permutation [prev] with time-decay [weight].
///
/// Penalizes:
/// - Fixed positions (elements remaining in same slot): +2 * weight
/// - Adjacent pairs preserved (order or reversed): +2 * weight
/// - First element matching: +6 * weight
/// - Last element matching: +3 * weight
/// - 100% Identical order: +1000
double similarity(List<String> cand, List<String> prev, double weight) {
  final int n = cand.length;
  int fixed = 0;
  for (int i = 0; i < n; i++) {
    if (cand[i] == prev[i]) fixed++;
  }

  final prevPairs = <String>{};
  for (int i = 0; i < n - 1; i++) {
    prevPairs.add('${prev[i]}|${prev[i + 1]}');
    prevPairs.add('${prev[i + 1]}|${prev[i]}');
  }

  int pairs = 0;
  for (int i = 0; i < n - 1; i++) {
    if (prevPairs.contains('${cand[i]}|${cand[i + 1]}')) {
      pairs++;
    }
  }

  final int first = cand[0] == prev[0] ? 1 : 0;
  final int last = cand[n - 1] == prev[n - 1] ? 1 : 0;
  final double identical = sameOrder(cand, prev) ? 1000.0 : 0.0;

  return weight * (fixed * 2 + pairs * 2 + first * 6 + last * 3) + identical;
}

/// Configuration options for [smartShuffle].
class SmartShuffleOptions {
  const SmartShuffleOptions({
    this.candidates = 24,
    this.keep = 5,
  });

  final int candidates;
  final int keep;
}

/// Generates all permutations of a small list of strings.
List<List<String>> _generatePermutations(List<String> list) {
  if (list.length <= 1) return [list];
  final result = <List<String>>[];
  for (int i = 0; i < list.length; i++) {
    final current = list[i];
    final remaining = List<String>.from(list)..removeAt(i);
    for (final p in _generatePermutations(remaining)) {
      result.add([current, ...p]);
    }
  }
  return result;
}

/// Anti-pattern layer: generates K candidate shuffles, scores each against
/// recent saved orders for the same list multiset, and keeps the least similar.
///
/// Guaranteed properties:
/// - Never mutates [ids].
/// - For n < 2, returns a copy as-is.
/// - For n == 2, alternates between the two permutations avoiding immediate repeat.
/// - For n >= 3, never returns an order identical to any of the last [keep] orders.
/// - Avoids streaks of identical first items across consecutive runs.
List<String> smartShuffle(
  List<String> ids,
  List<List<String>> history, {
  SmartShuffleOptions opts = const SmartShuffleOptions(),
}) {
  final int n = ids.length;
  if (n < 2) return List<String>.from(ids);

  // Filter history to keep only previous orders that match the current set of items
  final recent = history.where((h) => sameSet(h, ids)).toList();
  final sliced = recent.length > opts.keep
      ? recent.sublist(recent.length - opts.keep)
      : recent;
  final recentReversed = sliced.reversed.toList(); // Newest first (age = 0)

  if (recentReversed.isEmpty || n == 2) {
    var out = fisherYates(ids);
    if (recentReversed.isNotEmpty && sameOrder(out, recentReversed.first)) {
      out = out.reversed.toList();
    }
    return out;
  }

  List<String> best = List<String>.from(ids);
  double bestScore = double.infinity;

  for (int c = 0; c < opts.candidates; c++) {
    final cand = fisherYates(ids);
    final isIdenticalToRecent =
        recentReversed.any((r) => sameOrder(cand, r));

    double score = 0.0;
    for (int age = 0; age < recentReversed.length; age++) {
      score += similarity(cand, recentReversed[age], 1.0 / (age + 1));
    }

    if (sameOrder(cand, ids)) {
      score += 50.0; // Avoid returning the un-shuffled original input
    }

    if (isIdenticalToRecent) {
      // Strongly penalize matching any of the recent orders for n >= 3
      score += 100000.0;
    }

    // Penalize repeating the same first element consecutively
    int consecutiveFirst = 0;
    for (final r in recentReversed) {
      if (r.isNotEmpty && r.first == cand.first) {
        consecutiveFirst++;
      } else {
        break;
      }
    }
    if (consecutiveFirst >= 2) {
      score += 50.0 * consecutiveFirst;
    }
    if (consecutiveFirst >= 3) {
      score += 50000.0; // Strictly prevent 4th identical first element in a row
    }

    if (score < bestScore) {
      bestScore = score;
      best = cand;
      if (score == 0.0) break;
    }
  }

  // Invariant guarantee: Never return an order identical to any recent order for n >= 3
  if (recentReversed.any((r) => sameOrder(best, r))) {
    // Generate up to 100 random permutations searching for a non-identical one
    for (int retry = 0; retry < 100; retry++) {
      final cand = fisherYates(ids);
      if (!recentReversed.any((r) => sameOrder(cand, r))) {
        best = cand;
        break;
      }
    }

    // For n == 3 (6 total permutations), if all random attempts collided,
    // deterministically pick the remaining unused permutation
    if (n == 3 && recentReversed.any((r) => sameOrder(best, r))) {
      final allPerms = _generatePermutations(ids);
      for (final p in allPerms) {
        if (!recentReversed.any((r) => sameOrder(p, r))) {
          best = p;
          break;
        }
      }
    }
  }

  return best;
}

/// State of a shuffle-bag for winner selection.
class BagState {
  const BagState({
    required this.remaining,
    this.lastPicked,
  });

  final List<String> remaining;
  final String? lastPicked;

  Map<String, dynamic> toMap() => {
        'remaining': remaining,
        'lastPicked': lastPicked,
      };

  factory BagState.fromMap(Map<String, dynamic> map) {
    return BagState(
      remaining: List<String>.from(map['remaining'] ?? const []),
      lastPicked: map['lastPicked'] as String?,
    );
  }
}

/// Result returned from [pickFromBag].
class PickResult {
  const PickResult({
    required this.picked,
    required this.state,
  });

  final String picked;
  final BagState state;
}

/// Winner / "pick one" mode: shuffle-bag.
/// Each name is picked once before any name repeats.
/// The last winner cannot be first in the next bag.
PickResult pickFromBag(List<String> ids, BagState? state) {
  if (ids.isEmpty) {
    throw ArgumentError('empty list');
  }

  // Filter out any IDs that were removed from the input list
  List<String> remaining = (state?.remaining ?? [])
      .where((id) => ids.contains(id))
      .toList();
  final String? lastPicked = state?.lastPicked;

  if (remaining.isEmpty) {
    remaining = fisherYates(ids);
    // If the next pop would repeat the last winner, swap it with another slot
    if (ids.length > 1 && remaining.last == lastPicked) {
      final int k = randomInt(remaining.length - 1);
      final temp = remaining[remaining.length - 1];
      remaining[remaining.length - 1] = remaining[k];
      remaining[k] = temp;
    }
  }

  final String picked = remaining.last;
  return PickResult(
    picked: picked,
    state: BagState(
      remaining: remaining.sublist(0, remaining.length - 1),
      lastPicked: picked,
    ),
  );
}

/// Storage interface / cache for persisting the last 5 orders and BagState.
class ShuffleMemory {
  ShuffleMemory._();
  static final ShuffleMemory instance = ShuffleMemory._();

  final Map<String, List<List<String>>> _inMemoryOrders = {};
  final Map<String, BagState> _inMemoryBags = {};

  dynamic _storageBox;

  /// Optionally attach a Hive box for offline persistence.
  void attachStorageBox(dynamic box) {
    _storageBox = box;
  }

  /// Derives a stable key for a group or ad-hoc list.
  String getListKey({String? groupId, required List<String> names}) {
    if (groupId != null && groupId.trim().isNotEmpty) {
      return 'group_${groupId.trim()}';
    }
    final sorted = names.map((n) => n.trim()).toList()..sort();
    return 'adhoc_${sorted.join('\u0000')}';
  }

  /// Retrieves the last saved orders for a list key (oldest first).
  List<List<String>> getRecentOrders(String listKey) {
    try {
      if (_storageBox != null) {
        final raw = _storageBox.get('orders_$listKey');
        if (raw is List) {
          return raw
              .whereType<List>()
              .map((inner) => inner.whereType<String>().toList())
              .toList();
        }
      }
    } catch (_) {}
    return _inMemoryOrders[listKey] ?? const [];
  }

  /// Records a newly completed order (keeps the last 5).
  void recordOrder(String listKey, List<String> order) {
    try {
      final current = getRecentOrders(listKey);
      final updated = [...current, List<String>.from(order)];
      final kept = updated.length > 5
          ? updated.sublist(updated.length - 5)
          : updated;
      _inMemoryOrders[listKey] = kept;
      if (_storageBox != null) {
        _storageBox.put('orders_$listKey', kept);
      }
    } catch (_) {}
  }

  /// Retrieves the persisted [BagState] for a list key.
  BagState? getBagState(String listKey) {
    try {
      if (_storageBox != null) {
        final raw = _storageBox.get('bag_$listKey');
        if (raw is Map) {
          return BagState.fromMap(Map<String, dynamic>.from(raw));
        }
      }
    } catch (_) {}
    return _inMemoryBags[listKey];
  }

  /// Persists the updated [BagState] for a list key.
  void saveBagState(String listKey, BagState state) {
    try {
      _inMemoryBags[listKey] = state;
      if (_storageBox != null) {
        _storageBox.put('bag_$listKey', state.toMap());
      }
    } catch (_) {}
  }

  /// Clears the shuffle memory for [listKey], or all shuffle memories if null.
  void resetMemory([String? listKey]) {
    try {
      if (listKey != null) {
        _inMemoryOrders.remove(listKey);
        _inMemoryBags.remove(listKey);
        if (_storageBox != null) {
          _storageBox.delete('orders_$listKey');
          _storageBox.delete('bag_$listKey');
        }
      } else {
        _inMemoryOrders.clear();
        _inMemoryBags.clear();
        if (_storageBox != null) {
          final keys = List.from(_storageBox.keys);
          for (final k in keys) {
            final s = k.toString();
            if (s.startsWith('orders_') || s.startsWith('bag_')) {
              _storageBox.delete(k);
            }
          }
        }
      }
    } catch (_) {}
  }
}

/// Global helper to reset shuffle memory.
void resetShuffleMemory([String? listKey]) {
  ShuffleMemory.instance.resetMemory(listKey);
}
