import '../models/reaction_model.dart';

class ReactionDefinitions {
  // Positive
  static const love = ReactionDefinition(
    id: 'love',
    name: 'Fell in Love',
    emoji: '😍',
    category: ReactionCategory.positive,
    consequence: ConsequenceType.speedBoost,
    dialogue: 'OMG! You are so cute! ❤️',
    scorePoints: 50,
    coinReward: 15,
    speedMultiplier: 1.3,
    consequenceDuration: 5.0,
  );

  static const kissBack = ReactionDefinition(
    id: 'kiss_back',
    name: 'Kissed Back',
    emoji: '😘',
    category: ReactionCategory.positive,
    consequence: ConsequenceType.speedBoost,
    dialogue: 'Muah! Here is one for you! 💋',
    scorePoints: 80,
    coinReward: 20,
    speedMultiplier: 1.4,
    consequenceDuration: 6.0,
  );

  static const gift = ReactionDefinition(
    id: 'gift',
    name: 'Heart Gift',
    emoji: '🎁',
    category: ReactionCategory.positive,
    consequence: ConsequenceType.coinReward,
    dialogue: 'Take these coins, darling! 💰',
    scorePoints: 40,
    coinReward: 35,
    consequenceDuration: 3.0,
  );

  static const join = ReactionDefinition(
    id: 'join',
    name: 'Joined Squad',
    emoji: '👫',
    category: ReactionCategory.positive,
    consequence: ConsequenceType.followerBonus,
    dialogue: "I'm coming with you! Let's go!",
    scorePoints: 60,
    coinReward: 10,
    consequenceDuration: 8.0,
  );

  // Neutral / Funny
  static const laugh = ReactionDefinition(
    id: 'laugh',
    name: 'Uncontrollable Laugh',
    emoji: '😂',
    category: ReactionCategory.neutral,
    consequence: ConsequenceType.chainReactionTrigger,
    dialogue: 'PFFT! Hahahaha are you for real?!',
    scorePoints: 25,
    coinReward: 5,
    chainReactionChance: 0.6,
    alertNearbyNPCs: true,
  );

  static const runAway = ReactionDefinition(
    id: 'run_away',
    name: 'Blushing Escape',
    emoji: '😳',
    category: ReactionCategory.neutral,
    consequence: ConsequenceType.none,
    dialogue: 'Eeeek! Too shy, gotta run!! 🏃‍♀️',
    scorePoints: 30,
    coinReward: 10,
    speedMultiplier: 1.2,
  );

  static const freeze = ReactionDefinition(
    id: 'freeze',
    name: 'Stunned Freeze',
    emoji: '😵',
    category: ReactionCategory.neutral,
    consequence: ConsequenceType.timeSlow,
    dialogue: '...Did that just happen?! ⚡',
    scorePoints: 35,
    coinReward: 8,
    speedMultiplier: 0.5,
    consequenceDuration: 4.0,
  );

  static const takePhoto = ReactionDefinition(
    id: 'take_photo',
    name: 'Selfie Flash',
    emoji: '📸',
    category: ReactionCategory.neutral,
    consequence: ConsequenceType.fameBoost,
    dialogue: 'Say cheese! Going viral on Insta! ✨',
    scorePoints: 75,
    coinReward: 12,
  );

  // Negative
  static const slap = ReactionDefinition(
    id: 'slap',
    name: 'Cartoon Slap',
    emoji: '💥',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.slapDamage,
    dialogue: 'SLAP! How dare you! 😤',
    scorePoints: 5,
    healthDelta: -1,
    speedMultiplier: 0.65,
    consequenceDuration: 2.0,
    chainReactionChance: 0.35,
  );

  static const chase = ReactionDefinition(
    id: 'chase',
    name: 'Furious Chase',
    emoji: '😡',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.chasePlayer,
    dialogue: 'GET BACK HERE RIGHT NOW!! 🤬',
    scorePoints: 20,
    speedMultiplier: 1.45,
    consequenceDuration: 8.0,
    chainReactionChance: 0.5,
  );

  static const scream = ReactionDefinition(
    id: 'scream',
    name: 'Loud Scream',
    emoji: '😱',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.chainReactionTrigger,
    dialogue: 'AHHHHHHH!! STRANGER DANGER!! 📢',
    scorePoints: 15,
    alertNearbyNPCs: true,
    chainReactionChance: 0.75,
  );

  static const callFriends = ReactionDefinition(
    id: 'call_friends',
    name: 'Calling Backup',
    emoji: '📱',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.callFriends,
    dialogue: 'Squad! Help me catch this troublemaker! 👥',
    scorePoints: 25,
    consequenceDuration: 10.0,
    chainReactionChance: 0.8,
  );

  static const callPolice = ReactionDefinition(
    id: 'call_police',
    name: 'Police Alert',
    emoji: '🚔',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.callPolice,
    dialogue: 'Officer! Arrest this person immediately!! 🚨',
    scorePoints: 50,
    healthDelta: 0,
    consequenceDuration: 12.0,
    chainReactionChance: 0.9,
    alertNearbyNPCs: true,
  );

  static const throwObject = ReactionDefinition(
    id: 'throw_object',
    name: 'Throwing Handbag',
    emoji: '👝',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.throwObstacle,
    dialogue: 'Catch this, you punk! 🎯',
    scorePoints: 20,
    consequenceDuration: 4.0,
  );

  static const crowd = ReactionDefinition(
    id: 'crowd',
    name: 'Crowd Surrounding',
    emoji: '👥',
    category: ReactionCategory.negative,
    consequence: ConsequenceType.crowdBlock,
    dialogue: 'Hey! Look what he did! Block the exit! 🚧',
    scorePoints: 30,
    chainReactionChance: 0.85,
    alertNearbyNPCs: true,
  );

  static final Map<String, ReactionDefinition> all = {
    love.id: love,
    kissBack.id: kissBack,
    gift.id: gift,
    join.id: join,
    laugh.id: laugh,
    runAway.id: runAway,
    freeze.id: freeze,
    takePhoto.id: takePhoto,
    slap.id: slap,
    chase.id: chase,
    scream.id: scream,
    callFriends.id: callFriends,
    callPolice.id: callPolice,
    throwObject.id: throwObject,
    crowd.id: crowd,
  };
}
