import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/models/models.dart';

void main() {
  group('CoinTossEntry Model Tests', () {
    test('should create with auto-generated id', () {
      final entry = CoinTossEntry(isHeads: true);
      expect(entry.id, isNotEmpty);
      expect(entry.isHeads, true);
      expect(entry.resultText, 'Heads');
      expect(entry.side, CoinSide.heads);
    });

    test('should create Tails entry', () {
      final entry = CoinTossEntry(isHeads: false);
      expect(entry.isHeads, false);
      expect(entry.resultText, 'Tails');
      expect(entry.side, CoinSide.tails);
    });

    test('should serialize to map and back', () {
      final entry = CoinTossEntry(isHeads: false);
      final map = entry.toMap();
      final restored = CoinTossEntry.fromMap(map);
      expect(restored.id, entry.id);
      expect(restored.isHeads, false);
      expect(restored.resultText, 'Tails');
    });

    test('equality based on id', () {
      final a = CoinTossEntry(id: 't1', isHeads: true);
      final b = CoinTossEntry(id: 't1', isHeads: false);
      final c = CoinTossEntry(id: 't2', isHeads: true);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('True Random Coin Distribution (1000 Tosses)', () {
    test('50/50 Statistical Distribution Test', () {
      int heads = 0;
      int tails = 0;

      final rand = Random();
      for (int i = 0; i < 1000; i++) {
        if (rand.nextBool()) {
          heads++;
        } else {
          tails++;
        }
      }

      // Expected ~500 each, allow statistically normal tolerance [400, 600]
      expect(heads, greaterThan(400));
      expect(heads, lessThan(600));
      expect(tails, greaterThan(400));
      expect(tails, lessThan(600));
      expect(heads + tails, equals(1000));
    });
  });
}
