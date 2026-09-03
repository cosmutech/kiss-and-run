import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static const String _kHeartCoins = 'heart_coins';
  static const String _kHighScore = 'high_score';
  static const String _kBestCombo = 'best_combo';
  static const String _kTotalKisses = 'total_kisses';
  static const String _kTotalEscapes = 'total_escapes';
  static const String _kTotalChains = 'total_chains';
  static const String _kHighestLevel = 'highest_level';
  static const String _kUnlockedItems = 'unlocked_items';
  static const String _kEquippedCustoms = 'equipped_customs';
  static const String _kLastDailyDate = 'last_daily_date';
  static const String _kDailyStreak = 'daily_streak';
  static const String _kSoundEnabled = 'sound_enabled';
  static const String _kVibrationEnabled = 'vibration_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Heart Coins
  static int getHeartCoins() => _prefs?.getInt(_kHeartCoins) ?? 150; // Starting gift!
  static Future<void> addHeartCoins(int amount) async {
    final current = getHeartCoins();
    await _prefs?.setInt(_kHeartCoins, current + amount);
  }
  static Future<bool> spendHeartCoins(int amount) async {
    final current = getHeartCoins();
    if (current >= amount) {
      await _prefs?.setInt(_kHeartCoins, current - amount);
      return true;
    }
    return false;
  }

  // Scores
  static int getHighScore() => _prefs?.getInt(_kHighScore) ?? 0;
  static Future<void> saveHighScore(int score) async {
    if (score > getHighScore()) {
      await _prefs?.setInt(_kHighScore, score);
    }
  }

  static int getBestCombo() => _prefs?.getInt(_kBestCombo) ?? 0;
  static Future<void> saveBestCombo(int combo) async {
    if (combo > getBestCombo()) {
      await _prefs?.setInt(_kBestCombo, combo);
    }
  }

  // Stats
  static int getTotalKisses() => _prefs?.getInt(_kTotalKisses) ?? 0;
  static Future<void> incrementKisses(int count) async {
    await _prefs?.setInt(_kTotalKisses, getTotalKisses() + count);
  }

  static int getTotalEscapes() => _prefs?.getInt(_kTotalEscapes) ?? 0;
  static Future<void> incrementEscapes() async {
    await _prefs?.setInt(_kTotalEscapes, getTotalEscapes() + 1);
  }

  static int getTotalChains() => _prefs?.getInt(_kTotalChains) ?? 0;
  static Future<void> incrementChains() async {
    await _prefs?.setInt(_kTotalChains, getTotalChains() + 1);
  }

  // Levels
  static int getHighestLevel() => _prefs?.getInt(_kHighestLevel) ?? 1;
  static Future<void> unlockLevel(int level) async {
    if (level > getHighestLevel()) {
      await _prefs?.setInt(_kHighestLevel, level);
    }
  }

  // Unlocked items
  static List<String> getUnlockedItems() {
    return _prefs?.getStringList(_kUnlockedItems) ??
        ['char_male', 'char_female', 'hair_0', 'shirt_0', 'pants_0', 'acc_0'];
  }

  static Future<void> unlockItem(String id) async {
    final items = getUnlockedItems();
    if (!items.contains(id)) {
      items.add(id);
      await _prefs?.setStringList(_kUnlockedItems, items);
    }
  }

  // Equipped customization
  static Map<String, dynamic> getEquippedCustoms() {
    final jsonStr = _prefs?.getString(_kEquippedCustoms);
    if (jsonStr != null) {
      try {
        return jsonDecode(jsonStr);
      } catch (_) {}
    }
    return {
      'gender': 'male',
      'hair': 0,
      'shirt': 0,
      'pants': 0,
      'accessory': 0,
    };
  }

  static Future<void> saveEquippedCustoms(Map<String, dynamic> customs) async {
    await _prefs?.setString(_kEquippedCustoms, jsonEncode(customs));
  }

  // Daily Rewards
  static String? getLastDailyDate() => _prefs?.getString(_kLastDailyDate);
  static int getDailyStreak() => _prefs?.getInt(_kDailyStreak) ?? 0;

  static Future<void> claimDailyReward(int nextStreak) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs?.setString(_kLastDailyDate, today);
    await _prefs?.setInt(_kDailyStreak, nextStreak);
  }

  // Settings
  static bool isSoundEnabled() => _prefs?.getBool(_kSoundEnabled) ?? true;
  static Future<void> setSoundEnabled(bool val) async =>
      _prefs?.setBool(_kSoundEnabled, val);

  static bool isVibrationEnabled() =>
      _prefs?.getBool(_kVibrationEnabled) ?? true;
  static Future<void> setVibrationEnabled(bool val) async =>
      _prefs?.setBool(_kVibrationEnabled, val);

  // Reset Progress
  static Future<void> resetAll() async {
    await _prefs?.clear();
  }
}
