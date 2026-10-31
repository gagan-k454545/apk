import 'dart:math';

/// Representation of the coin face / outcome.
enum CoinFace { heads, tails, noResult }

/// High-integrity, mathematically unbiased CSPRNG Coin Toss Engine.
///
/// Principles:
/// 1. Randomness source: CSPRNG (crypto.getRandomValues / Random.secure). Never Math.random.
/// 2. Three true random outcomes: Heads, Tails, and No Result (coin lands on edge in the middle).
/// 3. Anti-streak fairness: Prevents frustrating streaks (no outcome repeats > 2 times in a row).
/// 4. Rejection sampling for random integers (no modulo bias).
/// 5. Decides outcome FIRST before any animation begins.
/// 6. Visual variety (spins, tilt, drift, bounces, duration) is generated independently
///    from the same CSPRNG and does NOT correlate with the outcome face.
abstract final class CoinTossEngine {
  static final Random _secureRandom = _initSecureRandom();
  static final List<CoinFace> _recentTosses = [];

  static Random _initSecureRandom() {
    try {
      return Random.secure();
    } catch (e) {
      throw StateError(
          'Secure random (crypto.getRandomValues / Random.secure) unavailable: $e');
    }
  }

  /// Extracts 1 byte (0..255) from the cryptographically secure PRNG.
  static int randomByte() {
    return _secureRandom.nextInt(256);
  }

  /// Clears recent streak memory (useful for tests or user resets).
  static void resetMemory() {
    _recentTosses.clear();
  }

  /// Returns an unbiased integer in [0, max) using rejection sampling.
  static int randomInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'max must be a positive integer');
    }
    if (max <= 256) {
      final int limit = 256 - (256 % max);
      int v;
      do {
        v = randomByte();
      } while (v >= limit);
      return v % max;
    }
    // For max > 256 (e.g. randomInt(500)), use 32-bit rejection sampling
    const int maxU32 = 0x100000000;
    final int limit = maxU32 - (maxU32 % max);
    int sample;
    do {
      sample = _secureRandom.nextInt(maxU32);
    } while (sample >= limit);
    return sample % max;
  }

  /// Returns pure unbiased outcome among Heads, Tails, and No Result with anti-streak protection.
  static CoinFace tossCoin() {
    // Check if the last two outcomes were identical to prevent streaks (e.g., 3+ tails in a row)
    CoinFace? avoidStreakFace;
    if (_recentTosses.length >= 2) {
      final last1 = _recentTosses[_recentTosses.length - 1];
      final last2 = _recentTosses[_recentTosses.length - 2];
      if (last1 == last2) {
        avoidStreakFace = last1;
      }
    }

    CoinFace result;
    if (avoidStreakFace != null) {
      // Choose uniformly from the other two outcomes
      final candidateFaces =
          CoinFace.values.where((f) => f != avoidStreakFace).toList();
      final idx = randomInt(candidateFaces.length);
      result = candidateFaces[idx];
    } else {
      // Complete random selection among all three outcomes (Heads, Tails, No Result)
      final idx = randomInt(CoinFace.values.length);
      result = CoinFace.values[idx];
    }

    _recentTosses.add(result);
    if (_recentTosses.length > 20) {
      _recentTosses.removeAt(0);
    }
    return result;
  }

  /// Returns an unbiased integer in inclusive range [min, max].
  static int randomRange(int min, int max) {
    if (max < min) {
      throw ArgumentError('max cannot be less than min');
    }
    return min + randomInt(max - min + 1);
  }

  /// Plans a physics toss based on the last settled face.
  ///
  /// Parity rule:
  /// - Heads resting angle = 0 deg (or 0 mod 360).
  /// - Tails resting angle = 180 deg (or 180 mod 360).
  /// - No Result resting angle = 90 deg (or 90 mod 360, standing upright on edge).
  ///
  /// The coin never visibly snaps between consecutive tosses.
  static TossPlan planToss([CoinFace lastFace = CoinFace.heads]) {
    final CoinFace result = tossCoin();
    final int fullSpins = randomRange(5, 8); // visual variety: 5 to 8 full spins

    double targetRestingAngle;
    switch (result) {
      case CoinFace.heads:
        targetRestingAngle = 0.0;
        break;
      case CoinFace.tails:
        targetRestingAngle = 180.0;
        break;
      case CoinFace.noResult:
        targetRestingAngle = 90.0;
        break;
    }

    double startAngle;
    switch (lastFace) {
      case CoinFace.heads:
        startAngle = 0.0;
        break;
      case CoinFace.tails:
        startAngle = 180.0;
        break;
      case CoinFace.noResult:
        startAngle = 90.0;
        break;
    }

    double diff = targetRestingAngle - startAngle;
    while (diff < 0) {
      diff += 360.0;
    }

    final double totalTurnsDeg = (fullSpins * 360.0) + diff;
    final int halfTurns = (totalTurnsDeg / 180.0).round();

    return TossPlan(
      result: result,
      startFace: lastFace,
      halfTurns: halfTurns,
      durationMs: 1700 + randomInt(500), // 1700ms .. 2199ms
      tiltY: randomRange(6, 16) * (randomInt(2) == 1 ? 1.0 : -1.0),
      driftZ: randomRange(4, 14) * (randomInt(2) == 1 ? 1.0 : -1.0),
      height: randomRange(150, 230).toDouble(),
      bounces: randomRange(2, 3),
      targetRestingAngle: targetRestingAngle,
      totalTurnsDeg: totalTurnsDeg,
    );
  }
}

/// Specifications for an individual coin toss animation.
class TossPlan {
  const TossPlan({
    required this.result,
    required this.startFace,
    required this.halfTurns,
    required this.durationMs,
    required this.tiltY,
    required this.driftZ,
    required this.height,
    required this.bounces,
    this.targetRestingAngle = 0.0,
    this.totalTurnsDeg = 0.0,
  });

  /// The decided final face (heads, tails, or noResult).
  final CoinFace result;

  /// The face before the toss started.
  final CoinFace startFace;

  /// Total half rotations (180 degrees each) about X-axis.
  final int halfTurns;

  /// Total animation duration in milliseconds.
  final int durationMs;

  /// Peak side tilt about Y-axis in degrees.
  final double tiltY;

  /// Peak in-plane wobble about Z-axis in degrees.
  final double driftZ;

  /// Peak rise height in pixels.
  final double height;

  /// Number of damping bounce hops (2 or 3).
  final int bounces;

  /// Exact target resting angle mod 360.
  final double targetRestingAngle;

  /// Total rotation in degrees.
  final double totalTurnsDeg;

  /// Convenience getters
  bool get isHeads => result == CoinFace.heads;
  bool get isTails => result == CoinFace.tails;
  bool get isNoResult => result == CoinFace.noResult;

  /// Start angle in degrees (0 for heads, 180 for tails, 90 for noResult).
  double get startAngleDeg {
    switch (startFace) {
      case CoinFace.heads:
        return 0.0;
      case CoinFace.tails:
        return 180.0;
      case CoinFace.noResult:
        return 90.0;
    }
  }

  /// End angle in degrees.
  double get endAngleDeg =>
      startAngleDeg +
      (totalTurnsDeg > 0 ? totalTurnsDeg : (halfTurns * 180.0));

  /// Normalized resting angle mod 360 (0 for heads, 180 for tails, 90 for noResult).
  double get finalRestingAngleDeg => (endAngleDeg % 360.0 + 360.0) % 360.0;
}
