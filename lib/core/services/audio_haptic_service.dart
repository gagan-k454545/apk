import 'package:flutter/services.dart';
import '../../models/app_settings.dart';
import 'audio_web_delegate.dart';

/// Audio and Haptic Synthesis Service matching Section 5:
/// - Unlocks on first user gesture.
/// - WebAudio synthesis for whoosh, apex flight tick, landing clink (3 inharmonic partials),
///   damped bounce clinks, and result pop.
/// - Native platform fallback to HapticFeedback and SystemSound.
/// - Fail-safe: never throws if audio context is blocked or unavailable.
class AudioHapticService {
  const AudioHapticService();

  /// Unlocks audio context on user gesture (e.g. Toss button press or coin tap).
  void unlock() {
    try {
      WebAudioDelegate.unlock();
    } catch (_) {}
  }

  /// 1. Launch Whoosh (0.35s bandpass sweeping 500Hz to 2200Hz).
  void playLaunch(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (settings.soundEnabled) {
      try {
        WebAudioDelegate.whoosh();
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// 2. Apex Flight Tick (quiet ting at peak).
  void playSpinTick(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
    if (settings.soundEnabled) {
      try {
        WebAudioDelegate.tick();
      } catch (_) {}
    }
  }

  /// 3. Landing Clink (3 inharmonic sine partials ~2400Hz, 3700Hz, 5300Hz, 0.35s decay).
  void playLanding(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (settings.soundEnabled) {
      try {
        WebAudioDelegate.clink();
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// 4. Damped Bounce Clink (quieter clink at landing hops).
  void playBounce(AppSettings settings, double gain) {
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (settings.soundEnabled) {
      try {
        WebAudioDelegate.clink(0, gain);
      } catch (_) {}
    }
  }

  /// 5. Result Reveal Pop (soft pop 660Hz to 880Hz, 120ms).
  void playResult(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (settings.soundEnabled) {
      try {
        WebAudioDelegate.pop();
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }
}
