enum ReactionCategory { positive, neutral, negative }

enum ConsequenceType {
  none,
  speedBoost,
  coinReward,
  followerBonus,
  timeSlow,
  fameBoost,
  slapDamage,
  chasePlayer,
  callFriends,
  callPolice,
  throwObstacle,
  crowdBlock,
  chainReactionTrigger,
}

class ReactionDefinition {
  final String id;
  final String name;
  final String emoji;
  final ReactionCategory category;
  final ConsequenceType consequence;
  final String dialogue;
  final int scorePoints;
  final int coinReward;
  final int healthDelta; // e.g. -1 for slap
  final double speedMultiplier; // e.g. 1.35 for speed boost, 0.7 for slap slow
  final double consequenceDuration; // in seconds
  final double chainReactionChance; // 0.0 to 1.0
  final bool alertNearbyNPCs;

  const ReactionDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.consequence,
    required this.dialogue,
    this.scorePoints = 10,
    this.coinReward = 0,
    this.healthDelta = 0,
    this.speedMultiplier = 1.0,
    this.consequenceDuration = 4.0,
    this.chainReactionChance = 0.0,
    this.alertNearbyNPCs = false,
  });
}
