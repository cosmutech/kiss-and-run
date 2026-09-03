import 'dart:math';
import '../models/npc_model.dart';
import '../models/obstacle_model.dart';

class ChainReactionEvent {
  final String title;
  final String description;
  final int bonusPoints;
  final double x;
  final double y;

  const ChainReactionEvent({
    required this.title,
    required this.description,
    required this.bonusPoints,
    required this.x,
    required this.y,
  });
}

class ChainReactionManager {
  final Random _rnd = Random();

  /// Check collisions between chasers and other pedestrians/obstacles
  List<ChainReactionEvent> processChaserCollisions({
    required List<NPCModel> npcs,
    required List<ObstacleModel> obstacles,
    required double chainChance,
  }) {
    final List<ChainReactionEvent> newEvents = [];
    final List<NPCModel> chasers = npcs.where((n) => n.isChasing).toList();

    for (final chaser in chasers) {
      for (final target in npcs) {
        if (target.id == chaser.id || target.isChasing || target.isKissed) {
          continue;
        }

        final double dx = (chaser.x - target.x).abs();
        final double dy = (chaser.y - target.y).abs();

        // Check proximity collision
        if (dx < 40 && dy < 35) {
          if (_rnd.nextDouble() < chainChance) {
            // Trigger chain reaction!
            target.isChasing = true;
            target.currentSpeed = target.baseSpeed * 1.35;
            target.facingDirection = chaser.facingDirection;

            String reactionMsg = 'HEY! WATCH OUT!! 😡';
            int bonus = 100;

            if (target.typeId == 'security_guard' || target.typeId == 'police_officer') {
              reactionMsg = 'HALT IN THE NAME OF THE LAW! 🚨';
              bonus = 200;
            } else if (target.typeId == 'street_vendor' || target.typeId == 'food_worker') {
              reactionMsg = 'MY FOOD CART!! CATCH HIM! 🌭';
              bonus = 150;
              // Spawn food cart spill obstacle
              obstacles.add(ObstacleModel(
                id: 'spill_${DateTime.now().millisecondsSinceEpoch}',
                type: ObstacleType.coffeeSpill,
                name: 'Spilled Drink',
                emoji: '🥤',
                x: target.x,
                y: target.y + 10,
              ));
            }

            target.say(reactionMsg, duration: 3.0);

            newEvents.add(ChainReactionEvent(
              title: 'CHAIN REACTION!',
              description: reactionMsg,
              bonusPoints: bonus,
              x: target.x,
              y: target.y - 30,
            ));
          }
        }
      }
    }

    return newEvents;
  }
}
