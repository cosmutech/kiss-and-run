import 'dart:math';
import '../models/npc_model.dart';
import '../models/obstacle_model.dart';

class ChainReactionEvent {
  final String title;
  final String description;
  final int bonusPoints;
  final double lane;
  final double z;

  const ChainReactionEvent({
    required this.title,
    required this.description,
    required this.bonusPoints,
    required this.lane,
    required this.z,
  });
}

class ChainReactionManager {
  final Random _rnd = Random();

  /// Check chain collisions between chaser and nearby pedestrians/food carts in 3D lanes
  List<ChainReactionEvent> processChaserCollisions({
    required List<NPCModel> npcs,
    required List<ObstacleModel> obstacles,
    required double playerZ,
    required bool hasChaser,
    required double chainChance,
  }) {
    final List<ChainReactionEvent> newEvents = [];
    if (!hasChaser) return newEvents;

    for (final npc in npcs) {
      if (npc.isChasing || npc.isKissed) continue;

      // When player passes an NPC while being chased
      final double dz = (npc.z - playerZ).abs();
      if (dz < 80 && _rnd.nextDouble() < chainChance * 0.08) {
        npc.isChasing = true;
        String msg = 'HEY! LOOK OUT!! 😡';
        int bonus = 100;

        if (npc.typeId == 'security_guard' || npc.typeId == 'police_officer') {
          msg = 'HALT! BACKUP REQUESTED! 🚨';
          bonus = 200;
        } else if (npc.typeId == 'street_vendor' || npc.typeId == 'food_worker') {
          msg = 'MY FOOD CART!! SLIPPERY ROAD! 🌭';
          bonus = 150;
          obstacles.add(ObstacleModel(
            id: 'spill_${DateTime.now().millisecondsSinceEpoch}',
            type: ObstacleType.bananaPeel,
            name: 'Food Spill',
            emoji: '🍌',
            lane: npc.lane,
            z: npc.z + 50,
          ));
        }

        npc.say(msg, duration: 2.5);

        newEvents.add(ChainReactionEvent(
          title: 'CHAIN REACTION!',
          description: msg,
          bonusPoints: bonus,
          lane: npc.lane,
          z: npc.z,
        ));
      }
    }

    return newEvents;
  }
}
