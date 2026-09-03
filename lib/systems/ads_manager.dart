import 'dart:async';
import 'package:flutter/foundation.dart';

class AdsManager {
  static bool _hasRemovedAds = false;
  static int _runsSinceLastInterstitial = 0;

  static bool get hasRemovedAds => _hasRemovedAds;

  static void init() {
    debugPrint('AdsManager: Initialized AdMob Architecture');
  }

  static void setRemoveAds(bool val) {
    _hasRemovedAds = val;
  }

  /// Show a simulated/live rewarded ad.
  /// Used for: Revive on game-over, Double Coins at end of run.
  static Future<bool> showRewardedAd({required VoidCallback onRewardEarned}) async {
    debugPrint('AdsManager: Showing Rewarded Ad...');
    // Simulate brief watch buffer (e.g. 1.2s) in dev / fallback mode
    await Future.delayed(const Duration(milliseconds: 1200));
    onRewardEarned();
    return true;
  }

  /// Show interstitial ad between level finishes (not after every kiss)
  static void onRunCompleted() {
    if (_hasRemovedAds) return;
    _runsSinceLastInterstitial++;
    if (_runsSinceLastInterstitial >= 3) {
      _runsSinceLastInterstitial = 0;
      debugPrint('AdsManager: Showing Interstitial Ad between runs');
    }
  }
}
