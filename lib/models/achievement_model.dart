class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int rewardCoins;
  final int targetValue;
  int currentValue;
  bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.rewardCoins,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'currentValue': currentValue,
    'isUnlocked': isUnlocked,
  };
}
