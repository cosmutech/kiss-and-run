import 'package:flutter/services.dart';
import 'save_manager.dart';

enum SoundType {
  kiss,
  slap,
  scream,
  coin,
  boing,
  siren,
  cheer,
  slip,
  whoosh,
  click,
}

class SoundManager {
  static void play(SoundType type) {
    if (!SaveManager.isSoundEnabled()) return;

    // Platform sound feedback
    switch (type) {
      case SoundType.kiss:
      case SoundType.coin:
      case SoundType.click:
        SystemSound.play(SystemSoundType.click);
        if (SaveManager.isVibrationEnabled()) {
          HapticFeedback.lightImpact();
        }
        break;
      case SoundType.slap:
      case SoundType.slip:
        SystemSound.play(SystemSoundType.alert);
        if (SaveManager.isVibrationEnabled()) {
          HapticFeedback.heavyImpact();
        }
        break;
      case SoundType.siren:
      case SoundType.scream:
        SystemSound.play(SystemSoundType.alert);
        if (SaveManager.isVibrationEnabled()) {
          HapticFeedback.vibrate();
        }
        break;
      case SoundType.boing:
      case SoundType.whoosh:
      case SoundType.cheer:
        SystemSound.play(SystemSoundType.click);
        if (SaveManager.isVibrationEnabled()) {
          HapticFeedback.mediumImpact();
        }
        break;
    }
  }

  static void hapticLight() {
    if (SaveManager.isVibrationEnabled()) {
      HapticFeedback.lightImpact();
    }
  }

  static void hapticHeavy() {
    if (SaveManager.isVibrationEnabled()) {
      HapticFeedback.heavyImpact();
    }
  }
}
