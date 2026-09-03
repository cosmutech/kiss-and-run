import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../models/npc_model.dart';
import '../models/obstacle_model.dart';
import '../models/powerup_model.dart';
import '../models/level_model.dart';
import '../models/reaction_model.dart';
import '../data/reaction_definitions.dart';
import '../data/npc_definitions.dart';
import '../data/funny_dialogues.dart';
import '../rendering/particle_system.dart';
import '../rendering/game_world_painter.dart';
import 'chain_reaction_manager.dart';
import 'sound_manager.dart';
import 'save_manager.dart';

enum GameStatus { playing, paused, gameOver, levelComplete }

class GameController extends ChangeNotifier {
  final Random _rnd = Random();
  final ChainReactionManager _chainManager = ChainReactionManager();
  final ParticleSystem particleSystem = ParticleSystem();

  late LevelModel currentLevel;
  late PlayerModel player;
  final List<NPCModel> npcs = [];
  final List<ObstacleModel> obstacles = [];
  final List<PowerUpModel> powerUps = [];
  final List<FloatingText> floatingTexts = [];

  GameStatus status = GameStatus.playing;

  // Camera and world
  double cameraX = 0.0;
  double animTime = 0.0;
  double screenShake = 0.0;

  // Run statistics
  int score = 0;
  int combo = 1;
  double comboTimer = 0.0;
  int runHeartCoins = 0;
  int kissCount = 0;
  int escapeCount = 0;
  int chainReactionCount = 0;
  double distanceTraveled = 0.0;

  // Active interaction
  NPCModel? eligibleKissTarget;
  String? activeEventBanner;
  double eventBannerTimer = 0.0;

  // Mobile movement input (-1.0 to 1.0)
  double inputX = 0.0;
  double inputY = 0.0;

  GameController({required LevelModel level}) {
    currentLevel = level;
    _initLevel();
  }

  void _initLevel() {
    player = PlayerModel(
      x: 150,
      y: 300,
      baseSpeed: 220,
    );

    // Apply saved customization
    final customs = SaveManager.getEquippedCustoms();
    player.gender = customs['gender'] ?? 'male';
    player.hairStyleIndex = customs['hair'] ?? 0;
    player.shirtColorIndex = customs['shirt'] ?? 0;
    player.pantsColorIndex = customs['pants'] ?? 0;
    player.accessoryIndex = customs['accessory'] ?? 0;

    npcs.clear();
    obstacles.clear();
    powerUps.clear();
    floatingTexts.clear();
    particleSystem.clear();

    score = 0;
    combo = 1;
    comboTimer = 0;
    runHeartCoins = 0;
    kissCount = 0;
    escapeCount = 0;
    chainReactionCount = 0;
    distanceTraveled = 0;
    cameraX = 0;
    status = GameStatus.playing;

    _populateWorld();
  }

  void _populateWorld() {
    final worldLen = currentLevel.isEndless ? 5000.0 : currentLevel.worldLength;
    double spawnX = 350.0;

    // Spawn initial NPCs
    while (spawnX < worldLen - 200) {
      final pool = currentLevel.npcPool;
      final typeId = pool[_rnd.nextInt(pool.length)];
      final config = NPCDefinitions.getById(typeId);

      npcs.add(NPCModel(
        id: 'npc_${npcs.length}_${_rnd.nextInt(1000)}',
        typeId: config.id,
        name: config.name,
        gender: config.gender,
        hairColor: config.hairColor,
        shirtColor: config.shirtColor,
        pantsColor: config.pantsColor,
        skinTone: config.skinTone,
        accessoryEmoji: config.accessoryEmoji,
        x: spawnX,
        y: 220.0 + (_rnd.nextDouble() * 180.0),
        baseSpeed: config.baseSpeed,
        currentSpeed: config.baseSpeed,
        facingDirection: _rnd.nextBool() ? 1.0 : -1.0,
        reactionWeights: config.reactionWeights,
      ));

      // Chance to spawn an obstacle
      if (_rnd.nextDouble() < currentLevel.obstacleFrequency) {
        _spawnRandomObstacle(spawnX + 60);
      }

      // Chance to spawn a power-up
      if (_rnd.nextDouble() < 0.18) {
        _spawnRandomPowerUp(spawnX + 110);
      }

      spawnX += 140.0 + (_rnd.nextDouble() * 120.0);
    }
  }

  void _spawnRandomObstacle(double x) {
    final types = [
      ObstacleType.bananaPeel,
      ObstacleType.coffeeSpill,
      ObstacleType.barricade,
      ObstacleType.foodCart,
    ];
    final type = types[_rnd.nextInt(types.length)];
    String name = 'Banana';
    String emoji = '🍌';

    switch (type) {
      case ObstacleType.bananaPeel:
        name = 'Banana Peel';
        emoji = '🍌';
        break;
      case ObstacleType.coffeeSpill:
        name = 'Spilled Coffee';
        emoji = '☕';
        break;
      case ObstacleType.barricade:
        name = 'Traffic Cone';
        emoji = '🚧';
        break;
      case ObstacleType.foodCart:
        name = 'Food Cart';
        emoji = '🌭';
        break;
      default:
        break;
    }

    obstacles.add(ObstacleModel(
      id: 'obs_${obstacles.length}',
      type: type,
      name: name,
      emoji: emoji,
      x: x,
      y: 240.0 + (_rnd.nextDouble() * 160.0),
    ));
  }

  void _spawnRandomPowerUp(double x) {
    final pTypes = [
      PowerUpType.heartShield,
      PowerUpType.speedBoost,
      PowerUpType.heartMagnet,
      PowerUpType.slowMotion,
      PowerUpType.angelMode,
      PowerUpType.chaosMode,
    ];
    final type = pTypes[_rnd.nextInt(pTypes.length)];
    String name = 'PowerUp';
    String emoji = '⚡';

    switch (type) {
      case PowerUpType.heartShield:
        name = 'Heart Shield';
        emoji = '🛡️';
        break;
      case PowerUpType.speedBoost:
        name = 'Speed Boost';
        emoji = '⚡';
        break;
      case PowerUpType.heartMagnet:
        name = 'Heart Magnet';
        emoji = '🧲';
        break;
      case PowerUpType.slowMotion:
        name = 'Slow Motion';
        emoji = '🕐';
        break;
      case PowerUpType.angelMode:
        name = 'Angel Mode';
        emoji = '😇';
        break;
      case PowerUpType.chaosMode:
        name = 'Chaos Mode';
        emoji = '😈';
        break;
    }

    powerUps.add(PowerUpModel(
      id: 'pu_${powerUps.length}',
      type: type,
      name: name,
      iconEmoji: emoji,
      description: name,
      x: x,
      y: 230.0 + (_rnd.nextDouble() * 160.0),
    ));
  }

  /// Primary 60 FPS Game Loop
  void update(double dt) {
    if (status != GameStatus.playing) return;

    animTime += dt;

    // Decay screenshake
    if (screenShake > 0) {
      screenShake = (screenShake - dt * 2.5).clamp(0.0, 1.0);
    }

    // Update Banner timer
    if (eventBannerTimer > 0) {
      eventBannerTimer -= dt;
      if (eventBannerTimer <= 0) activeEventBanner = null;
    }

    // Update Combo timer
    if (combo > 1) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = 1;
      }
    }

    // Update Player
    _updatePlayer(dt);

    // Update NPCs
    _updateNPCs(dt);

    // Update Obstacles
    _updateObstacles(dt);

    // Check Chain Reactions
    _updateChainReactions();

    // Check Collisions & Pickups
    _checkPowerUpPickups();
    _checkObstacleCollisions();
    _checkChaserCatchPlayer();

    // Update Particles
    particleSystem.update(dt);

    // Update Floating texts
    for (final ft in floatingTexts) {
      ft.life += dt;
      ft.y -= 25 * dt;
    }
    floatingTexts.removeWhere((ft) => ft.isDead);

    // Smooth Camera Follow
    final targetCamX = player.x - 180;
    cameraX += (targetCamX - cameraX) * 0.12;
    if (cameraX < 0) cameraX = 0;

    // Check Endless Generation
    if (currentLevel.isEndless && player.x > npcs.last.x - 800) {
      _expandEndlessWorld();
    }

    // Check Level Win Condition
    if (!currentLevel.isEndless && kissCount >= currentLevel.targetKisses && player.x >= currentLevel.worldLength - 200) {
      _triggerLevelComplete();
    }

    notifyListeners();
  }

  void _updatePlayer(double dt) {
    // Timers
    if (player.invincibilityTimer > 0) player.invincibilityTimer -= dt;
    if (player.speedBoostTimer > 0) player.speedBoostTimer -= dt;
    if (player.slowMoTimer > 0) player.slowMoTimer -= dt;
    if (player.angelTimer > 0) player.angelTimer -= dt;
    if (player.chaosTimer > 0) player.chaosTimer -= dt;

    if (player.stunTimer > 0) {
      player.stunTimer -= dt;
      player.vx = 0;
      player.vy = 0;
      return;
    }

    // Jumping physics
    if (player.jumpProgress > 0) {
      player.jumpProgress += dt * 2.8;
      if (player.jumpProgress >= 1.0) player.jumpProgress = 0;
    }

    // Speed calculation
    double speed = player.baseSpeed;
    if (player.hasSpeedBoost) speed *= 1.45;
    if (player.hasSlowMo) speed *= 0.8;

    // Movement from input
    player.vx = inputX * speed;
    player.vy = inputY * speed;

    if (inputX.abs() > 0.05) {
      player.facingDirection = inputX > 0 ? 1.0 : -1.0;
    }

    player.x += player.vx * dt;
    player.y += player.vy * dt;

    // Constrain to road/sidewalk bounds
    player.x = player.x.clamp(50.0, currentLevel.isEndless ? double.infinity : currentLevel.worldLength - 50);
    player.y = player.y.clamp(200.0, 520.0);

    // Distance tracking
    if (player.x > distanceTraveled) {
      distanceTraveled = player.x;
    }

    // Check proximity to eligible NPCs for KISS button
    eligibleKissTarget = null;
    for (final npc in npcs) {
      if (!npc.canBeKissed || npc.isKissed) continue;
      final dist = (Offset(player.x, player.y) - Offset(npc.x, npc.y)).distance;
      if (dist < 60) {
        eligibleKissTarget = npc;
        break;
      }
    }
  }

  void _updateNPCs(double dt) {
    for (final npc in npcs) {
      // Speech bubble timer
      if (npc.speechBubbleTimer > 0) {
        npc.speechBubbleTimer -= dt;
        if (npc.speechBubbleTimer <= 0) npc.speechBubble = null;
      }

      // Reaction timer
      if (npc.reactionTimer > 0) {
        npc.reactionTimer -= dt;
      }

      if (npc.isChasing) {
        // Run directly toward player!
        final dx = player.x - npc.x;
        final dy = player.y - npc.y;
        final angle = atan2(dy, dx);

        final speed = npc.currentSpeed * (player.hasSlowMo ? 0.6 : 1.0);
        npc.vx = cos(angle) * speed;
        npc.vy = sin(angle) * speed;
        npc.facingDirection = dx >= 0 ? 1.0 : -1.0;

        npc.x += npc.vx * dt;
        npc.y += npc.vy * dt;
      } else if (npc.isFollowing) {
        // Follow player happily behind
        final targetX = player.x - (player.facingDirection * 50);
        final targetY = player.y;
        final dx = targetX - npc.x;
        final dy = targetY - npc.y;
        npc.vx = dx * 1.5;
        npc.vy = dy * 1.5;
        npc.facingDirection = player.facingDirection;

        npc.x += npc.vx * dt;
        npc.y += npc.vy * dt;
      } else {
        // Peaceful wander / stroll
        npc.x += (npc.facingDirection * npc.currentSpeed * 0.4) * dt;
        // Turn around occasionally
        if (_rnd.nextDouble() < 0.005) {
          npc.facingDirection *= -1.0;
        }
      }

      npc.y = npc.y.clamp(200.0, 520.0);
    }
  }

  void _updateObstacles(double dt) {
    for (final obs in obstacles) {
      if (obs.type == ObstacleType.thrownObject) {
        obs.x += obs.vx * dt;
        obs.y += obs.vy * dt;
      }
    }
  }

  void _updateChainReactions() {
    final events = _chainManager.processChaserCollisions(
      npcs: npcs,
      obstacles: obstacles,
      chainChance: currentLevel.chainReactionChance * (player.isChaos ? 1.5 : 1.0),
    );

    for (final e in events) {
      chainReactionCount++;
      addScore(e.bonusPoints);
      SoundManager.play(SoundType.scream);
      screenShake = 0.5;

      floatingTexts.add(FloatingText(
        text: '🔥 CHAIN REACTION! +${e.bonusPoints}',
        color: Colors.deepOrangeAccent,
        x: e.x,
        y: e.y,
      ));

      activeEventBanner = 'DOMINO CHAOS! 💥';
      eventBannerTimer = 2.0;
    }
  }

  void _checkPowerUpPickups() {
    for (final pu in powerUps) {
      if (pu.isCollected) continue;
      final dist = (Offset(player.x, player.y) - Offset(pu.x, pu.y)).distance;

      // Heart Magnet pulls powerups & coins toward player
      if (player.hasMagnet && dist < 140) {
        final angle = atan2(player.y - pu.y, player.x - pu.x);
        pu.x += cos(angle) * 250 * 0.016;
        pu.y += sin(angle) * 250 * 0.016;
      }

      if (dist < 42) {
        pu.isCollected = true;
        _applyPowerUp(pu);
      }
    }
  }

  void _applyPowerUp(PowerUpModel pu) {
    SoundManager.play(SoundType.coin);
    particleSystem.spawnCoinSparkles(pu.x, pu.y);

    floatingTexts.add(FloatingText(
      text: '${pu.iconEmoji} ${pu.name}!',
      color: Colors.amberAccent,
      x: pu.x,
      y: pu.y - 20,
    ));

    switch (pu.type) {
      case PowerUpType.heartShield:
        player.hasShield = true;
        break;
      case PowerUpType.speedBoost:
        player.speedBoostTimer = pu.duration;
        break;
      case PowerUpType.heartMagnet:
        player.magnetTimer = pu.duration;
        break;
      case PowerUpType.slowMotion:
        player.slowMoTimer = pu.duration;
        break;
      case PowerUpType.angelMode:
        player.angelTimer = pu.duration;
        break;
      case PowerUpType.chaosMode:
        player.chaosTimer = pu.duration;
        break;
    }
  }

  void _checkObstacleCollisions() {
    if (player.isJumping) return; // Can jump over low obstacles

    for (final obs in obstacles) {
      if (obs.hasCollided) continue;
      final dist = (Offset(player.x, player.y) - Offset(obs.x, obs.y)).distance;

      if (dist < 32) {
        obs.hasCollided = true;
        SoundManager.play(SoundType.slip);
        particleSystem.spawnStars(obs.x, obs.y);

        if (obs.type == ObstacleType.bananaPeel || obs.type == ObstacleType.coffeeSpill) {
          player.stunTimer = 0.8;
          floatingTexts.add(FloatingText(
            text: 'SLIPPED! 🍌',
            color: Colors.yellowAccent,
            x: obs.x,
            y: obs.y - 20,
          ));
        } else {
          player.takeDamage(1);
          screenShake = 0.7;
          floatingTexts.add(FloatingText(
            text: 'OUCH! -1 ❤️',
            color: Colors.redAccent,
            x: obs.x,
            y: obs.y - 20,
          ));
        }

        if (player.health <= 0) {
          _triggerGameOver();
        }
      }
    }
  }

  void _checkChaserCatchPlayer() {
    if (player.isInvincible) return;

    for (final npc in npcs) {
      if (!npc.isChasing) continue;
      final dist = (Offset(player.x, player.y) - Offset(npc.x, npc.y)).distance;

      if (dist < 34) {
        // Tackled / caught!
        player.takeDamage(1);
        screenShake = 0.8;
        SoundManager.play(SoundType.slap);
        particleSystem.spawnAnger(player.x, player.y);

        floatingTexts.add(FloatingText(
          text: 'TACKLED! 💥',
          color: Colors.redAccent,
          x: player.x,
          y: player.y - 25,
        ));

        // Push chaser slightly back
        npc.x -= npc.facingDirection * 40;

        if (player.health <= 0) {
          _triggerGameOver();
          break;
        }
      }
    }
  }

  /// The Core Kiss Action!
  void performKiss() {
    final target = eligibleKissTarget;
    if (target == null || !target.canBeKissed) return;

    player.state = PlayerState.kissing;
    player.facingDirection = target.x >= player.x ? 1.0 : -1.0;

    // Pick reaction based on personality weights (or angel guaranteed positive)
    ReactionDefinition reaction;
    if (player.isAngel) {
      reaction = ReactionDefinitions.love;
    } else {
      reaction = _pickReactionForNPC(target);
    }

    target.triggerReaction(reaction);
    kissCount++;
    addScore(reaction.scorePoints * combo);
    combo++;
    comboTimer = 5.0; // 5 seconds window to continue combo!

    if (reaction.coinReward > 0) {
      runHeartCoins += reaction.coinReward;
      SaveManager.addHeartCoins(reaction.coinReward);
    }

    // Audio & visuals
    SoundManager.play(SoundType.kiss);
    particleSystem.spawnHearts(target.x, target.y);

    floatingTexts.add(FloatingText(
      text: '${reaction.emoji} ${reaction.name} +${reaction.scorePoints * combo}',
      color: reaction.category == ReactionCategory.positive ? Colors.pinkAccent : Colors.orangeAccent,
      x: target.x,
      y: target.y - 30,
    ));

    // Execute Consequence
    _executeReactionConsequence(target, reaction);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (player.state == PlayerState.kissing) {
        player.state = PlayerState.idle;
      }
    });

    notifyListeners();
  }

  ReactionDefinition _pickReactionForNPC(NPCModel npc) {
    double r = _rnd.nextDouble();
    double cumulative = 0.0;

    for (final entry in npc.reactionWeights.entries) {
      cumulative += entry.value;
      if (r <= cumulative) {
        return ReactionDefinitions.all[entry.key] ?? ReactionDefinitions.laugh;
      }
    }
    return ReactionDefinitions.laugh;
  }

  void _executeReactionConsequence(NPCModel npc, ReactionDefinition reaction) {
    switch (reaction.consequence) {
      case ConsequenceType.speedBoost:
        player.speedBoostTimer = reaction.consequenceDuration;
        activeEventBanner = 'SWEET RUSH! ⚡';
        eventBannerTimer = 2.0;
        break;

      case ConsequenceType.slapDamage:
        player.takeDamage(1);
        screenShake = 0.8;
        SoundManager.play(SoundType.slap);
        particleSystem.spawnAnger(player.x, player.y);
        activeEventBanner = FunnyDialogues.getRandom(FunnyDialogues.slapped);
        eventBannerTimer = 2.5;
        if (player.health <= 0) _triggerGameOver();
        break;

      case ConsequenceType.chasePlayer:
        activeEventBanner = 'RUN! THEY ARE FURIOUS!! 🏃💨';
        eventBannerTimer = 2.5;
        SoundManager.play(SoundType.scream);
        break;

      case ConsequenceType.callPolice:
        _spawnPoliceCarOrOfficer(npc.x + 250);
        activeEventBanner = FunnyDialogues.getRandom(FunnyDialogues.policeAlert);
        eventBannerTimer = 3.0;
        SoundManager.play(SoundType.siren);
        break;

      case ConsequenceType.callFriends:
        _spawnBackupChasers(npc.x + 120);
        activeEventBanner = 'THEY CALLED THE WHOLE SQUAD!! 👥';
        eventBannerTimer = 2.5;
        break;

      case ConsequenceType.throwObstacle:
        // Spawn thrown handbag towards player
        obstacles.add(ObstacleModel(
          id: 'thrown_${DateTime.now().millisecondsSinceEpoch}',
          type: ObstacleType.thrownObject,
          name: 'Handbag',
          emoji: '👝',
          x: npc.x,
          y: npc.y,
          vx: (player.x - npc.x) * 1.5,
          vy: (player.y - npc.y) * 1.5,
        ));
        break;

      case ConsequenceType.crowdBlock:
        _alertNearbyCrowd(npc);
        activeEventBanner = 'SURROUNDED BY SPECTATORS! 🚧';
        eventBannerTimer = 2.5;
        break;

      case ConsequenceType.timeSlow:
        player.slowMoTimer = 4.0;
        break;

      default:
        break;
    }
  }

  void _spawnPoliceCarOrOfficer(double x) {
    final police = NPCDefinitions.getById('police_officer');
    final pNpc = NPCModel(
      id: 'police_${DateTime.now().millisecondsSinceEpoch}',
      typeId: police.id,
      name: police.name,
      gender: police.gender,
      hairColor: police.hairColor,
      shirtColor: police.shirtColor,
      pantsColor: police.pantsColor,
      skinTone: police.skinTone,
      accessoryEmoji: police.accessoryEmoji,
      x: x,
      y: 320,
      baseSpeed: police.baseSpeed,
      currentSpeed: police.baseSpeed * 1.3,
      isChasing: true,
      reactionWeights: police.reactionWeights,
    );
    pNpc.say('PULL OVER AND STEP AWAY! 🚨', duration: 3.5);
    npcs.add(pNpc);
  }

  void _spawnBackupChasers(double x) {
    for (int i = 0; i < 2; i++) {
      final config = NPCDefinitions.getById('angry_guy');
      final buddy = NPCModel(
        id: 'buddy_${npcs.length}_$i',
        typeId: config.id,
        name: config.name,
        gender: config.gender,
        hairColor: config.hairColor,
        shirtColor: config.shirtColor,
        pantsColor: config.pantsColor,
        skinTone: config.skinTone,
        x: x + (i * 60),
        y: 260.0 + (i * 70),
        baseSpeed: config.baseSpeed,
        currentSpeed: config.baseSpeed * 1.25,
        isChasing: true,
        reactionWeights: config.reactionWeights,
      );
      buddy.say("WE'RE ON 'EM! 🥊", duration: 2.5);
      npcs.add(buddy);
    }
  }

  void _alertNearbyCrowd(NPCModel centerNpc) {
    for (final npc in npcs) {
      if ((Offset(npc.x, npc.y) - Offset(centerNpc.x, centerNpc.y)).distance < 160) {
        npc.say('WHOA! LOOK AT THAT! 👀', duration: 2.5);
        npc.vx = 0;
        npc.currentSpeed = 0;
      }
    }
  }

  void playerJump() {
    if (player.jumpProgress == 0) {
      player.jumpProgress = 0.01;
      SoundManager.play(SoundType.boing);
    }
  }

  void playerDash() {
    player.speedBoostTimer = 1.0;
    SoundManager.play(SoundType.whoosh);
  }

  void addScore(int points) {
    score += points;
    if (score > SaveManager.getHighScore()) {
      SaveManager.saveHighScore(score);
    }
    if (combo > SaveManager.getBestCombo()) {
      SaveManager.saveBestCombo(combo);
    }
  }

  void _expandEndlessWorld() {
    final lastX = npcs.last.x;
    for (int i = 0; i < 5; i++) {
      final pool = currentLevel.npcPool;
      final typeId = pool[_rnd.nextInt(pool.length)];
      final config = NPCDefinitions.getById(typeId);

      npcs.add(NPCModel(
        id: 'endless_${npcs.length}',
        typeId: config.id,
        name: config.name,
        gender: config.gender,
        hairColor: config.hairColor,
        shirtColor: config.shirtColor,
        pantsColor: config.pantsColor,
        skinTone: config.skinTone,
        accessoryEmoji: config.accessoryEmoji,
        x: lastX + 180 + (i * 140),
        y: 220.0 + (_rnd.nextDouble() * 180.0),
        baseSpeed: config.baseSpeed + (kissCount * 1.5), // Gradually scale difficulty
        currentSpeed: config.baseSpeed + (kissCount * 1.5),
        reactionWeights: config.reactionWeights,
      ));

      if (_rnd.nextDouble() < 0.25) {
        _spawnRandomObstacle(lastX + 220 + (i * 140));
      }
    }
  }

  void _triggerGameOver() {
    status = GameStatus.gameOver;
    SoundManager.play(SoundType.slap);
    activeEventBanner = FunnyDialogues.getRandom(FunnyDialogues.caught);

    SaveManager.saveHighScore(score);
    SaveManager.saveBestCombo(combo);
    SaveManager.incrementKisses(kissCount);
    notifyListeners();
  }

  void _triggerLevelComplete() {
    status = GameStatus.levelComplete;
    SoundManager.play(SoundType.cheer);
    addScore(500); // Level clear bonus!
    SaveManager.unlockLevel(currentLevel.levelNumber + 1);
    SaveManager.addHeartCoins(50); // Completion reward
    runHeartCoins += 50;
    notifyListeners();
  }

  void revivePlayer() {
    player.health = player.maxHealth;
    player.invincibilityTimer = 3.0;
    status = GameStatus.playing;
    // Push pursuers back
    for (final npc in npcs) {
      if (npc.isChasing) {
        npc.x -= npc.facingDirection * 150;
      }
    }
    notifyListeners();
  }

  void restartLevel() {
    _initLevel();
    notifyListeners();
  }
}
