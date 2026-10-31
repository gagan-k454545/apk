import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/core/services/audio_haptic_service.dart';
import 'package:shuffle_master/core/shuffle/coin_toss_engine.dart';
import 'package:shuffle_master/models/app_settings.dart';
import 'package:shuffle_master/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('Section 7: Coin Toss Unbiased CSPRNG Randomness Tests', () {
    test('1. tossCoin over 200,000 calls: heads share within 49.5% to 50.5%', () {
      const int trials = 200000;
      int headsCount = 0;

      for (int i = 0; i < trials; i++) {
        if (CoinTossEngine.tossCoin() == CoinFace.heads) {
          headsCount++;
        }
      }

      final double headsShare = (headsCount / trials) * 100.0;
      // Expect 50.0% with very tight statistical bounds: 49.5% to 50.5%
      expect(headsShare, greaterThanOrEqualTo(49.5));
      expect(headsShare, lessThanOrEqualTo(50.5));
    });

    test('2. randomInt(3) and randomInt(5) are uniform (chi-square) over 300,000 calls', () {
      const int trials = 300000;

      // Chi-square test for randomInt(3) (k = 3, df = 2, critical 0.01 = 9.21)
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

      // Chi-square test for randomInt(5) (k = 5, df = 4, critical 0.01 = 13.28)
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

    test('3. For 5,000 planToss() calls: final angle modulo 360 strictly matches face', () {
      const int trials = 5000;
      CoinFace currentFace = CoinFace.heads;
      int violations = 0;

      for (int i = 0; i < trials; i++) {
        final plan = CoinTossEngine.planToss(currentFace);

        if (plan.startFace != currentFace) violations++;

        if (plan.startFace == CoinFace.heads) {
          if (plan.result == CoinFace.tails && plan.halfTurns % 2 != 1) violations++;
          if (plan.result == CoinFace.heads && plan.halfTurns % 2 != 0) violations++;
        } else {
          if (plan.result == CoinFace.tails && plan.halfTurns % 2 != 0) violations++;
          if (plan.result == CoinFace.heads && plan.halfTurns % 2 != 1) violations++;
        }

        final double finalAngleMod360 = plan.finalRestingAngleDeg;
        if (plan.result == CoinFace.heads && finalAngleMod360.abs() > 0.001) violations++;
        if (plan.result == CoinFace.tails && (finalAngleMod360 - 180.0).abs() > 0.001) violations++;

        if (plan.durationMs < 1700 || plan.durationMs > 2200) violations++;
        if (plan.height < 150.0 || plan.height > 230.0) violations++;
        if (plan.bounces < 2 || plan.bounces > 3) violations++;

        currentFace = plan.result;
      }

      expect(violations, equals(0));
    });

    test('4. planToss outputs for heads vs tails have statistically similar duration/height (no visual tell)', () {
      const int trials = 5000;
      double headsDurationSum = 0;
      double tailsDurationSum = 0;
      int headsCount = 0;
      int tailsCount = 0;

      double headsHeightSum = 0;
      double tailsHeightSum = 0;

      for (int i = 0; i < trials; i++) {
        final plan = CoinTossEngine.planToss();
        if (plan.isHeads) {
          headsDurationSum += plan.durationMs;
          headsHeightSum += plan.height;
          headsCount++;
        } else {
          tailsDurationSum += plan.durationMs;
          tailsHeightSum += plan.height;
          tailsCount++;
        }
      }

      final meanHeadsDuration = headsDurationSum / headsCount;
      final meanTailsDuration = tailsDurationSum / tailsCount;
      final meanHeadsHeight = headsHeightSum / headsCount;
      final meanTailsHeight = tailsHeightSum / tailsCount;

      // No correlation / visual tell between duration/height and the face
      expect((meanHeadsDuration - meanTailsDuration).abs(), lessThan(35.0));
      expect((meanHeadsHeight - meanTailsHeight).abs(), lessThan(8.0));
    });

    test('5. Sound: AudioHapticService calls fail-safe without exceptions', () {
      const service = AudioHapticService();
      final settings = AppSettings.defaults();
      final mutedSettings = settings.copyWith(soundEnabled: false, hapticEnabled: false);

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
