import 'save_manager.dart';

class DailyRewardTier {
  final int day;
  final int coins;
  final String rewardLabel;
  final String iconEmoji;

  const DailyRewardTier({
    required this.day,
    required this.coins,
    required this.rewardLabel,
    required this.iconEmoji,
  });
}

class DailyRewardManager {
  static const List<DailyRewardTier> tiers = [
    DailyRewardTier(day: 1, coins: 100, rewardLabel: '100 Coins', iconEmoji: '💰'),
    DailyRewardTier(day: 2, coins: 150, rewardLabel: '150 Coins', iconEmoji: '💰'),
    DailyRewardTier(day: 3, coins: 250, rewardLabel: '250 Coins', iconEmoji: '🪙'),
    DailyRewardTier(day: 4, coins: 350, rewardLabel: '350 Coins + Shield', iconEmoji: '🛡️'),
    DailyRewardTier(day: 5, coins: 500, rewardLabel: '500 Coins', iconEmoji: '💎'),
    DailyRewardTier(day: 6, coins: 750, rewardLabel: '750 Coins + Shades', iconEmoji: '🕶️'),
    DailyRewardTier(day: 7, coins: 1000, rewardLabel: '1,000 Coins JACKPOT!', iconEmoji: '👑'),
  ];

  static bool canClaimToday() {
    final lastClaim = SaveManager.getLastDailyDate();
    if (lastClaim == null) return true;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastClaim != today;
  }

  static int getCurrentStreak() {
    return SaveManager.getDailyStreak();
  }

  static Future<DailyRewardTier> claimReward() async {
    int streak = getCurrentStreak();
    int currentDayIndex = streak % 7;
    final reward = tiers[currentDayIndex];

    await SaveManager.addHeartCoins(reward.coins);
    if (currentDayIndex == 5) {
      await SaveManager.unlockItem('acc_1'); // Shades
    } else if (currentDayIndex == 6) {
      await SaveManager.unlockItem('acc_4'); // Bandana
    }

    await SaveManager.claimDailyReward(streak + 1);
    return reward;
  }
}
