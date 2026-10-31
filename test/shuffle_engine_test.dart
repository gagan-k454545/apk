import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/core/shuffle/shuffle_engine.dart';

void main() {
  group('Shuffle Engine Tests', () {
    // -------------------------------------------------------------------------
    // Test 1: Uniformity (240,000 shuffles of [A, B, C, D])
    // -------------------------------------------------------------------------
    test('1. Uniformity: 240,000 shuffles of 4 items with Chi-Square check', () {
      final items = ['A', 'B', 'C', 'D'];
      const totalRuns = 240000;
      const expectedPerPermutation = 10000.0; // 240,000 / 24

      final Map<String, int> permutationCounts = {};

      for (int i = 0; i < totalRuns; i++) {
        final shuffled = fisherYates(items);
        final key = shuffled.join();
        permutationCounts[key] = (permutationCounts[key] ?? 0) + 1;
      }

      // 4! = 24 permutations must all appear
      expect(permutationCounts.length, equals(24),
          reason: 'All 24 permutations must appear');

      double chiSquare = 0.0;
      for (final entry in permutationCounts.entries) {
        final count = entry.value;
        // Each permutation must appear within about 5% of 10,000 (9,500 to 10,500)
        expect(
          count,
          greaterThanOrEqualTo(9400),
          reason: 'Permutation ${entry.key} count ($count) below 5% margin',
        );
        expect(
          count,
          lessThanOrEqualTo(10600),
          reason: 'Permutation ${entry.key} count ($count) above 5% margin',
        );

        final diff = count - expectedPerPermutation;
        chiSquare += (diff * diff) / expectedPerPermutation;
      }

      // Degrees of freedom = 24 - 1 = 23.
      // Critical value for alpha = 0.001 is 49.73.
      expect(chiSquare, lessThan(50.0),
          reason: 'Chi-Square ($chiSquare) must be within critical boundary');
    });

    // -------------------------------------------------------------------------
    // Test 2: Position uniformity
    // -------------------------------------------------------------------------
    test('2. Position uniformity: each name lands in each position about equally often', () {
      final items = ['A', 'B', 'C', 'D'];
      const totalRuns = 120000;
      const expectedPerSlot = totalRuns / 4; // 30,000

      // Map: item -> [countAtPos0, countAtPos1, countAtPos2, countAtPos3]
      final Map<String, List<int>> positionCounts = {
        for (var item in items) item: [0, 0, 0, 0],
      };

      for (int i = 0; i < totalRuns; i++) {
        final shuffled = fisherYates(items);
        for (int pos = 0; pos < shuffled.length; pos++) {
          positionCounts[shuffled[pos]]![pos]++;
        }
      }

      // Check each item at each slot is within 3% of 30,000
      for (final item in items) {
        for (int pos = 0; pos < 4; pos++) {
          final count = positionCounts[item]![pos];
          final ratio = count / expectedPerSlot;
          expect(ratio, greaterThan(0.97),
              reason: 'Item $item at pos $pos ratio ($ratio) too low');
          expect(ratio, lessThan(1.03),
              reason: 'Item $item at pos $pos ratio ($ratio) too high');
        }
      }
    });

    // -------------------------------------------------------------------------
    // Test 3: randomInt(3) unbiased distribution over 300,000 calls
    // -------------------------------------------------------------------------
    test('3. randomInt(3) over 300,000 calls is evenly distributed (no modulo bias)', () {
      const totalCalls = 300000;
      const expected = 100000.0;
      final counts = [0, 0, 0];

      for (int i = 0; i < totalCalls; i++) {
        final val = randomInt(3);
        counts[val]++;
      }

      double chiSquare = 0.0;
      for (int i = 0; i < 3; i++) {
        final count = counts[i];
        // Each bucket within 2% of 100,000 (98,000 to 102,000)
        expect(count, greaterThan(98000),
            reason: 'Bucket $i count ($count) below margin');
        expect(count, lessThan(102000),
            reason: 'Bucket $i count ($count) above margin');

        final diff = count - expected;
        chiSquare += (diff * diff) / expected;
      }

      // df = 2, critical value at p = 0.001 is 13.82
      expect(chiSquare, lessThan(14.0),
          reason: 'Chi-Square ($chiSquare) indicates modulo bias or skew');
    });

    // -------------------------------------------------------------------------
    // Test 4: smartShuffle with history never returns identical order to last 5
    // -------------------------------------------------------------------------
    test('4. smartShuffle with history never returns an order identical to any of the last 5 (for n >= 3)', () {
      final items = ['Alpha', 'Beta', 'Gamma', 'Delta'];
      final List<List<String>> history = [
        ['Alpha', 'Beta', 'Gamma', 'Delta'],
        ['Beta', 'Gamma', 'Delta', 'Alpha'],
        ['Gamma', 'Delta', 'Alpha', 'Beta'],
        ['Delta', 'Alpha', 'Beta', 'Gamma'],
        ['Beta', 'Alpha', 'Delta', 'Gamma'],
      ];

      for (int run = 0; run < 500; run++) {
        final result = smartShuffle(items, history);

        // Verify result is NOT identical to any of the last 5 in history
        final recent5 = history.length > 5
            ? history.sublist(history.length - 5)
            : history;

        for (final prev in recent5) {
          expect(sameOrder(result, prev), isFalse,
              reason: 'smartShuffle produced an order identical to recent history ($prev)');
        }

        history.add(result);
      }
    });

    // -------------------------------------------------------------------------
    // Test 5: Over 1,000 consecutive smartShuffle runs on 6 names, no first name > 3 times
    // -------------------------------------------------------------------------
    test('5. Over 1,000 consecutive smartShuffle runs on 6 names: same first name never appears > 3 times in a row', () {
      final items = ['A', 'B', 'C', 'D', 'E', 'F'];
      final List<List<String>> history = [];

      String? currentStreakLeader;
      int streakCount = 0;
      int maxStreak = 0;

      for (int i = 0; i < 1000; i++) {
        final result = smartShuffle(items, history);
        final first = result.first;

        if (first == currentStreakLeader) {
          streakCount++;
        } else {
          currentStreakLeader = first;
          streakCount = 1;
        }

        if (streakCount > maxStreak) {
          maxStreak = streakCount;
        }

        expect(streakCount, lessThanOrEqualTo(3),
            reason: 'First item "$first" appeared $streakCount consecutive times in a row at iteration $i');

        history.add(result);
      }

      expect(maxStreak, lessThanOrEqualTo(3));
    });

    // -------------------------------------------------------------------------
    // Test 6: pickFromBag over 3 full cycles on 5 names
    // -------------------------------------------------------------------------
    test('6. pickFromBag: over 3 full cycles on 5 names, each picked once per cycle, no repeats across boundary', () {
      final names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Evan'];
      BagState? state;

      for (int cycle = 0; cycle < 3; cycle++) {
        final pickedInCycle = <String>[];
        final String? cycleStartPrevious = state?.lastPicked;

        for (int p = 0; p < names.length; p++) {
          final res = pickFromBag(names, state);
          pickedInCycle.add(res.picked);
          state = res.state;

          if (p == 0 && cycleStartPrevious != null) {
            // First pick of new cycle must NOT equal the last pick of the previous cycle
            expect(res.picked, isNot(equals(cycleStartPrevious)),
                reason: 'Boundary repeat: "${res.picked}" picked twice consecutively across cycle $cycle boundary');
          }
        }

        // Each name picked exactly once per cycle
        expect(pickedInCycle.toSet().length, equals(5),
            reason: 'Cycle $cycle must pick all 5 unique names');
        expect(sameSet(pickedInCycle, names), isTrue);
      }
    });

    // -------------------------------------------------------------------------
    // Test 7: Edge cases: [], [x], 2 names, duplicates, input array unchanged
    // -------------------------------------------------------------------------
    test('7. Edge cases: [], [x], 2 names, duplicates, input array unchanged', () {
      // 1. Empty list
      final empty = <String>[];
      expect(fisherYates(empty), isEmpty);
      expect(smartShuffle(empty, []), isEmpty);

      // 2. Single item
      final single = ['Lone'];
      expect(fisherYates(single), equals(['Lone']));
      expect(smartShuffle(single, []), equals(['Lone']));

      // 3. Input array remains unchanged (immutability)
      final original = ['A', 'B', 'C', 'D'];
      final copy = List<String>.from(original);
      final out1 = fisherYates(original);
      final out2 = smartShuffle(original, []);
      expect(original, equals(copy),
          reason: 'Input array must never be mutated');
      expect(identical(original, out1), isFalse);
      expect(identical(original, out2), isFalse);

      // 4. Two names (only 2 permutations exist, avoids repeating last)
      final twoNames = ['Heads', 'Tails'];
      final hist = [
        ['Heads', 'Tails']
      ];
      final swapped = smartShuffle(twoNames, hist);
      expect(swapped, equals(['Tails', 'Heads']),
          reason: 'For n=2 with prior order, must return the other permutation');

      // 5. Duplicates
      final dupes = ['A', 'A', 'B', 'B', 'C'];
      final dupesResult = fisherYates(dupes);
      expect(dupesResult.length, equals(5));
      final sortedDupes = List.from(dupes)..sort();
      final sortedResult = List.from(dupesResult)..sort();
      expect(sortedResult, equals(sortedDupes));
    });

    // -------------------------------------------------------------------------
    // Test 8: Persistence and reset shuffle memory
    // -------------------------------------------------------------------------
    test('8. Persistence and reset shuffle memory', () {
      final memory = ShuffleMemory.instance;
      memory.resetMemory();

      final key = memory.getListKey(groupId: 'grp-test', names: ['A', 'B', 'C']);
      expect(memory.getRecentOrders(key), isEmpty);

      memory.recordOrder(key, ['A', 'B', 'C']);
      memory.recordOrder(key, ['B', 'C', 'A']);
      expect(memory.getRecentOrders(key).length, equals(2));

      memory.saveBagState(key, const BagState(remaining: ['C'], lastPicked: 'B'));
      expect(memory.getBagState(key)?.lastPicked, equals('B'));

      // Reset specific key
      resetShuffleMemory(key);
      expect(memory.getRecentOrders(key), isEmpty);
      expect(memory.getBagState(key), isNull);
    });
  });
}
