import 'package:flutter/services.dart';
import '../../models/app_settings.dart';

class AudioHapticService {
  const AudioHapticService();

  void playLaunch(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playSpinTick(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void playLanding(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playResult(AppSettings settings) {
    if (settings.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
