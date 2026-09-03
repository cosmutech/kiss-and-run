import 'package:flutter/material.dart';
import 'reaction_model.dart';

enum NPCState { idle, strolling, shocked, reacting, chasing, runningAway, following }

class NPCModel {
  final String id;
  final String typeId;
  final String name;
  final String gender;
  final Color hairColor;
  final Color shirtColor;
  final Color pantsColor;
  final Color skinTone;
  final String accessoryEmoji;

  double x;
  double y;
  double vx;
  double vy;
  double baseSpeed;
  double currentSpeed;
  double facingDirection; // 1.0 = right, -1.0 = left

  NPCState state;
  ReactionDefinition? activeReaction;
  double reactionTimer;
  String? speechBubble;
  double speechBubbleTimer;

  bool isKissed;
  bool isChasing;
  bool isFollowing;
  bool isAlerted;
  bool canBeKissed;

  // Personality weights for reactions
  final Map<String, double> reactionWeights;

  NPCModel({
    required this.id,
    required this.typeId,
    required this.name,
    required this.gender,
    required this.hairColor,
    required this.shirtColor,
    required this.pantsColor,
    required this.skinTone,
    this.accessoryEmoji = '',
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.baseSpeed = 100.0,
    this.currentSpeed = 100.0,
    this.facingDirection = -1.0,
    this.state = NPCState.strolling,
    this.activeReaction,
    this.reactionTimer = 0.0,
    this.speechBubble,
    this.speechBubbleTimer = 0.0,
    this.isKissed = false,
    this.isChasing = false,
    this.isFollowing = false,
    this.isAlerted = false,
    this.canBeKissed = true,
    required this.reactionWeights,
  });

  void triggerReaction(ReactionDefinition reaction) {
    activeReaction = reaction;
    reactionTimer = reaction.consequenceDuration;
    speechBubble = reaction.dialogue;
    speechBubbleTimer = 2.5;
    isKissed = true;
    canBeKissed = false;

    switch (reaction.consequence) {
      case ConsequenceType.chasePlayer:
      case ConsequenceType.callFriends:
      case ConsequenceType.callPolice:
        state = NPCState.chasing;
        isChasing = true;
        currentSpeed = baseSpeed * 1.55;
        break;
      case ConsequenceType.timeSlow:
        state = NPCState.shocked;
        currentSpeed = 0;
        break;
      case ConsequenceType.followerBonus:
        state = NPCState.following;
        isFollowing = true;
        break;
      case ConsequenceType.slapDamage:
        state = NPCState.reacting;
        currentSpeed = 0;
        break;
      default:
        state = NPCState.reacting;
        break;
    }
  }

  void say(String text, {double duration = 2.0}) {
    speechBubble = text;
    speechBubbleTimer = duration;
  }
}
