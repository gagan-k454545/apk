import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/core/services/audio_haptic_service.dart';
import 'package:shuffle_master/core/shuffle/coin_toss_engine.dart';
import 'package:shuffle_master/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CoinTossEntry Model Tests', () {
    test('should create Heads entry', () {
      final entry = CoinTossEntry(isHeads: true);
      expect(entry.id, isNotEmpty);
      expect(entry.isHeads, true);
      expect(entry.isTails, false);
      expect(entry.isNoResult, false);
      expect(entry.resultText, 'Heads');
      expect(entry.side, CoinSide.heads);
    });

    test('should create Tails entry', () {
      final entry = CoinTossEntry(isHeads: false);
      expect(entry.isHeads, false);
      expect(entry.isTails, true);
      expect(entry.isNoResult, false);
      expect(entry.resultText, 'Tails');
      expect(entry.side, CoinSide.tails);
    });

    test('should create No Result entry', () {
      final entry = CoinTossEntry(isHeads: false, outcome: CoinSide.noResult);
      expect(entry.isHeads, false);
      expect(entry.isTails, false);
      expect(entry.isNoResult, true);
      expect(entry.resultText, 'No Result');
      expect(entry.side, CoinSide.noResult);
    });

    test('should serialize to map and back for all outcomes', () {
      for (final side in CoinSide.values) {
        final entry = CoinTossEntry(
          isHeads: side == CoinSide.heads,
          outcome: side,
        );
        final map = entry.toMap();
        final restored = CoinTossEntry.fromMap(map);
        expect(restored.id, entry.id);
        expect(restored.outcome, side);
        expect(restored.resultText, entry.resultText);
      }
    });

    test('equality based on id', () {
      final a = CoinTossEntry(id: 't1', isHeads: true);
      final b = CoinTossEntry(id: 't1', isHeads: false);
      final c = CoinTossEntry(id: 't2', isHeads: true);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Section 7: Coin Toss Unbiased CSPRNG Randomness Tests', () {
    setUp(() {
      CoinTossEngine.resetMemory();
    });

    test('1. tossCoin over 90,000 calls: Heads, Tails, and No Result are evenly balanced', () {
      const int trials = 90000;
      final counts = <CoinFace, int>{
        CoinFace.heads: 0,
        CoinFace.tails: 0,
        CoinFace.noResult: 0,
      };

      for (int i = 0; i < trials; i++) {
        final outcome = CoinTossEngine.tossCoin();
        counts[outcome] = counts[outcome]! + 1;
      }

      // Expected ~30,000 each (33.33%). Bound between 30.0% and 36.6%.
      for (final face in CoinFace.values) {
        final share = (counts[face]! / trials) * 100.0;
        expect(share, greaterThan(30.0), reason: '$face share is too low');
        expect(share, lessThan(36.6), reason: '$face share is too high');
      }
    });

    test('2. Anti-Streak Protection: No outcome appears > 2 times consecutively over 20,000 tosses', () {
      const int trials = 20000;
      CoinFace? lastFace;
      int streak = 0;
      int maxStreak = 0;

      for (int i = 0; i < trials; i++) {
        final face = CoinTossEngine.tossCoin();
        if (face == lastFace) {
          streak++;
          if (streak > maxStreak) {
            maxStreak = streak;
          }
        } else {
          lastFace = face;
          streak = 1;
        }
      }

      // Anti-streak ensures max consecutive identical outcomes is strictly <= 2
      expect(maxStreak, lessThanOrEqualTo(2));
    });

    test('3. randomInt(3) and randomInt(5) are uniform (chi-square) over 300,000 calls', () {
      const int trials = 300000;

      // Chi-square test for randomInt(3)
      final counts3 = List<int>.filled(3, 0);
      for (int i = 0; i < trials; i++) {
        counts3[CoinTossEngine.randomInt(3)]++;
      }
      const double expected3 = trials / 3.0;
      double chiSq3 = 0.0;
      for (int i = 0; i < 3; i++) {
        final diff = counts3[i] - expected3;
        chiSq3 += (diff * diff) / expected3;
      }
      expect(chiSq3, lessThan(9.21));

      // Chi-square test for randomInt(5)
      final counts5 = List<int>.filled(5, 0);
      for (int i = 0; i < trials; i++) {
        counts5[CoinTossEngine.randomInt(5)]++;
      }
      const double expected5 = trials / 5.0;
      double chiSq5 = 0.0;
      for (int i = 0; i < 5; i++) {
        final diff = counts5[i] - expected5;
        chiSq5 += (diff * diff) / expected5;
      }
      expect(chiSq5, lessThan(13.28));
    });

    test('4. For 5,000 planToss() calls: final angle modulo 360 strictly matches face (0° Heads, 180° Tails, 90° No Result)', () {
      const int trials = 5000;
      CoinFace currentFace = CoinFace.heads;
      int violations = 0;

      for (int i = 0; i < trials; i++) {
        final plan = CoinTossEngine.planToss(currentFace);

        if (plan.startFace != currentFace) violations++;

        final double finalAngleMod360 = plan.finalRestingAngleDeg;

        if (plan.result == CoinFace.heads && finalAngleMod360.abs() > 0.001) {
          violations++;
        }
        if (plan.result == CoinFace.tails &&
            (finalAngleMod360 - 180.0).abs() > 0.001) {
          violations++;
        }
        if (plan.result == CoinFace.noResult &&
            (finalAngleMod360 - 90.0).abs() > 0.001) {
          violations++;
        }

        if (plan.durationMs < 1700 || plan.durationMs > 2200) violations++;
        if (plan.height < 150.0 || plan.height > 230.0) violations++;
        if (plan.bounces < 2 || plan.bounces > 3) violations++;

        currentFace = plan.result;
      }

      expect(violations, equals(0));
    });

    test('5. Sound: AudioHapticService calls fail-safe without exceptions', () {
      const service = AudioHapticService();
      final settings = AppSettings.defaults();
      final mutedSettings =
          settings.copyWith(soundEnabled: false, hapticEnabled: false);

      expect(() => service.unlock(), returnsNormally);
      expect(() => service.playLaunch(settings), returnsNormally);
      expect(() => service.playSpinTick(settings), returnsNormally);
      expect(() => service.playLanding(settings), returnsNormally);
      expect(() => service.playBounce(settings, 0.5), returnsNormally);
      expect(() => service.playResult(settings), returnsNormally);

      expect(() => service.playLaunch(mutedSettings), returnsNormally);
      expect(() => service.playLanding(mutedSettings), returnsNormally);
    });
  });
}
