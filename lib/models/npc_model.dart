import 'package:flutter/material.dart';
import 'reaction_model.dart';

enum NPCState { waiting, strolling, reacting, chasing }

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

  // 3D Lane placement: -1 = Left Lane, 0 = Center Lane, 1 = Right Lane, -1.8 = Left Sidewalk, 1.8 = Right Sidewalk
  double lane;
  double z; // Distance along track
  double speed;

  NPCState state;
  ReactionDefinition? activeReaction;
  double reactionTimer;
  String? speechBubble;
  double speechBubbleTimer;

  bool isKissed;
  bool isChasing;
  bool canBeKissed;

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
    required this.lane,
    required this.z,
    this.speed = 0.0,
    this.state = NPCState.waiting,
    this.activeReaction,
    this.reactionTimer = 0.0,
    this.speechBubble,
    this.speechBubbleTimer = 0.0,
    this.isKissed = false,
    this.isChasing = false,
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

    if (reaction.consequence == ConsequenceType.chasePlayer ||
        reaction.consequence == ConsequenceType.callFriends ||
        reaction.consequence == ConsequenceType.callPolice) {
      state = NPCState.chasing;
      isChasing = true;
    } else {
      state = NPCState.reacting;
    }
  }

  void say(String text, {double duration = 2.0}) {
    speechBubble = text;
    speechBubbleTimer = duration;
  }
}
