import 'dart:math';

/// Representation of the coin face.
enum CoinFace { heads, tails }

/// High-integrity, mathematically unbiased CSPRNG Coin Toss Engine.
///
/// Principles:
/// 1. Randomness source: CSPRNG (crypto.getRandomValues / Random.secure). Never Math.random.
/// 2. Outcome = ONE unbiased bit from secure byte: (byte & 1) == 0 ? heads : tails.
///    256 values split evenly (128 even, 128 odd), perfectly uniform 50/50.
/// 3. Rejection sampling for random integers (no modulo bias).
/// 4. Decides outcome FIRST before any animation begins.
/// 5. Visual variety (spins, tilt, drift, bounces, duration) is generated independently
///    from the same CSPRNG and does NOT correlate with the outcome face.
abstract final class CoinTossEngine {
  static final Random _secureRandom = _initSecureRandom();

  static Random _initSecureRandom() {
    try {
      return Random.secure();
    } catch (e) {
      throw StateError('Secure random (crypto.getRandomValues / Random.secure) unavailable: $e');
    }
  }

  /// Extracts 1 byte (0..255) from the cryptographically secure PRNG.
  static int randomByte() {
    return _secureRandom.nextInt(256);
  }

  /// Returns pure 50/50 unbiased coin face: heads or tails.
  static CoinFace tossCoin() {
    return (randomByte() & 1) == 0 ? CoinFace.heads : CoinFace.tails;
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
  /// - If result == lastFace, halfTurns is even (rotates full 360s, returns to same face).
  /// - If result != lastFace, halfTurns is odd (rotates to opposite face).
  ///
  /// The coin never visibly snaps between consecutive tosses.
  static TossPlan planToss([CoinFace lastFace = CoinFace.heads]) {
    final CoinFace result = tossCoin();
    final int fullSpins = randomRange(5, 8); // visual variety: 5 to 8 full spins
    final bool needsFlip = (result != lastFace);
    final int halfTurns = fullSpins * 2 + (needsFlip ? 1 : 0);

    return TossPlan(
      result: result,
      startFace: lastFace,
      halfTurns: halfTurns,
      durationMs: 1700 + randomInt(500), // 1700ms .. 2199ms
      tiltY: randomRange(6, 16) * (randomInt(2) == 1 ? 1.0 : -1.0),
      driftZ: randomRange(4, 14) * (randomInt(2) == 1 ? 1.0 : -1.0),
      height: randomRange(150, 230).toDouble(),
      bounces: randomRange(2, 3),
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
  });

  /// The decided final face.
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

  /// Convenience getter for whether result is Heads.
  bool get isHeads => result == CoinFace.heads;

  /// Start angle in degrees (0 for heads, 180 for tails).
  double get startAngleDeg => startFace == CoinFace.heads ? 0.0 : 180.0;

  /// End angle in degrees.
  double get endAngleDeg => startAngleDeg + (halfTurns * 180.0);

  /// Normalized resting angle mod 360 (0 for heads, 180 for tails).
  double get finalRestingAngleDeg => (endAngleDeg % 360.0 + 360.0) % 360.0;
}
