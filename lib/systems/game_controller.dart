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
import '../rendering/game_world_3d_painter.dart';
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
  final List<HeartCoinModel> coins = [];
  final List<PowerUpModel> powerUps = [];
  final List<FloatingText3D> floatingTexts = [];

  GameStatus status = GameStatus.playing;

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
  double nextSpawnZ = 300.0;

  NPCModel? eligibleKissTarget;
  String? activeEventBanner;
  double eventBannerTimer = 0.0;

  GameController({required LevelModel level}) {
    currentLevel = level;
    _initLevel();
  }

  void _initLevel() {
    player = PlayerModel(
      baseSpeed: 420.0,
      speed: 420.0,
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
    coins.clear();
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
    nextSpawnZ = 300.0;
    status = GameStatus.playing;

    _populateInitialTrack();
  }

  void _populateInitialTrack() {
    // Generate the first 2500m of track
    while (nextSpawnZ < 2500.0) {
      _generateTrackSegment(nextSpawnZ);
      nextSpawnZ += 180.0 + (_rnd.nextDouble() * 80.0);
    }
  }

  void _generateTrackSegment(double z) {
    // 1. Pick a lane for an NPC encounter
    final pool = currentLevel.npcPool;
    final typeId = pool[_rnd.nextInt(pool.length)];
    final config = NPCDefinitions.getById(typeId);
    final npcLane = (_rnd.nextInt(3) - 1).toDouble(); // -1, 0, or 1

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
      lane: npcLane,
      z: z,
      reactionWeights: config.reactionWeights,
    ));

    // 2. Spawn Hurdles & Barriers in other lanes (Subway Surfers style)
    for (int l = -1; l <= 1; l++) {
      if (l == npcLane.toInt()) continue; // Keep NPC lane clear to kiss!

      final r = _rnd.nextDouble();
      if (r < 0.45) {
        // Low roadblock: MUST JUMP!
        obstacles.add(ObstacleModel(
          id: 'obs_${obstacles.length}',
          type: ObstacleType.roadblockLow,
          name: 'Hurdle',
          emoji: '🚧',
          lane: l.toDouble(),
          z: z,
          requiresJump: true,
        ));
      } else if (r < 0.75) {
        // Overhead barrier: MUST SLIDE!
        obstacles.add(ObstacleModel(
          id: 'obs_${obstacles.length}',
          type: ObstacleType.overheadBarrier,
          name: 'Overhead Barrier',
          emoji: '⚠️',
          lane: l.toDouble(),
          z: z,
          requiresSlide: true,
        ));
      } else if (r < 0.90) {
        // Banana slip hazard
        obstacles.add(ObstacleModel(
          id: 'obs_${obstacles.length}',
          type: ObstacleType.bananaPeel,
          name: 'Banana Peel',
          emoji: '🍌',
          lane: l.toDouble(),
          z: z,
        ));
      }
    }

    // 3. Spawn Coin Arcs in free lanes
    final coinLane = (_rnd.nextInt(3) - 1).toDouble();
    for (int i = 0; i < 4; i++) {
      // Arched coins (like Subway Surfers jumps!)
      final coinHeight = sin((i / 3) * pi) * 70;
      coins.add(HeartCoinModel(
        id: 'c_${coins.length}',
        lane: coinLane,
        z: z + 60 + (i * 25),
        y: coinHeight,
      ));
    }

    // 4. Chance of Power-Up
    if (_rnd.nextDouble() < 0.22) {
      final pTypes = PowerUpType.values;
      final type = pTypes[_rnd.nextInt(pTypes.length)];
      String name = 'Power-Up';
      String emoji = '⚡';
      switch (type) {
        case PowerUpType.heartShield:
          name = 'Shield';
          emoji = '🛡️';
          break;
        case PowerUpType.speedBoost:
          name = 'Jet Boost';
          emoji = '⚡';
          break;
        case PowerUpType.heartMagnet:
          name = 'Magnet';
          emoji = '🧲';
          break;
        case PowerUpType.slowMotion:
          name = 'Slow-Mo';
          emoji = '🕐';
          break;
        case PowerUpType.angelMode:
          name = 'Angel';
          emoji = '😇';
          break;
        case PowerUpType.chaosMode:
          name = 'Chaos';
          emoji = '😈';
          break;
      }

      powerUps.add(PowerUpModel(
        id: 'pu_${powerUps.length}',
        type: type,
        name: name,
        iconEmoji: emoji,
        description: name,
        lane: (_rnd.nextInt(3) - 1).toDouble(),
        z: z + 120,
      ));
    }
  }

  /// 60 FPS Game Loop
  void update(double dt) {
    if (status != GameStatus.playing) return;

    animTime += dt;

    if (screenShake > 0) {
      screenShake = (screenShake - dt * 2.5).clamp(0.0, 1.0);
    }

    if (eventBannerTimer > 0) {
      eventBannerTimer -= dt;
      if (eventBannerTimer <= 0) activeEventBanner = null;
    }

    if (combo > 1) {
      comboTimer -= dt;
      if (comboTimer <= 0) combo = 1;
    }

    _updatePlayer(dt);
    _updateChaser(dt);
    _checkCollisions();
    _checkCoinPickups();
    _checkPowerUpPickups();
    _updateChainReactions();

    // Update Floating texts
    for (final ft in floatingTexts) {
      ft.life += dt;
      ft.y += 35 * dt;
    }
    floatingTexts.removeWhere((ft) => ft.isDead);

    particleSystem.update(dt);

    // Continuous Endless Track Spawning ahead of player (like Subway Surfers)
    if (player.z + 1800 > nextSpawnZ) {
      _generateTrackSegment(nextSpawnZ);
      nextSpawnZ += 180.0 + (_rnd.nextDouble() * 80.0);
    }

    // Clean up passed objects to maintain lightning-fast 60 FPS
    npcs.removeWhere((n) => n.z < player.z - 250);
    obstacles.removeWhere((o) => o.z < player.z - 250);
    coins.removeWhere((c) => c.z < player.z - 250);
    powerUps.removeWhere((p) => p.z < player.z - 250);

    // Check Level Complete in Campaign
    if (!currentLevel.isEndless && kissCount >= currentLevel.targetKisses && player.z >= currentLevel.worldLength) {
      _triggerLevelComplete();
    }

    notifyListeners();
  }

  void _updatePlayer(double dt) {
    // Buff timers
    if (player.invincibilityTimer > 0) player.invincibilityTimer -= dt;
    if (player.speedBoostTimer > 0) player.speedBoostTimer -= dt;
    if (player.slowMoTimer > 0) player.slowMoTimer -= dt;
    if (player.angelTimer > 0) player.angelTimer -= dt;
    if (player.chaosTimer > 0) player.chaosTimer -= dt;

    if (player.slideTimer > 0) {
      player.slideTimer -= dt;
      if (player.slideTimer <= 0 && !player.isJumping) {
        player.state = PlayerState.running;
      }
    }

    if (player.stunTimer > 0) {
      player.stunTimer -= dt;
      return;
    }

    // Smooth lane interpolation (Subway Surfers buttery lane change)
    final target = player.targetLane.toDouble();
    player.currentLanePos += (target - player.currentLanePos) * (14.0 * dt);

    // Jump Physics (Gravity & vertical velocity)
    if (player.isJumping || player.jumpVy != 0) {
      player.jumpVy -= 1600.0 * dt;
      player.jumpY += player.jumpVy * dt;

      if (player.jumpY <= 0) {
        player.jumpY = 0;
        player.jumpVy = 0;
        if (!player.isSliding) {
          player.state = PlayerState.running;
        }
      }
    }

    // Forward speed
    double currentSpeed = player.baseSpeed;
    if (player.hasSpeedBoost) currentSpeed *= 1.5;
    if (player.hasSlowMo) currentSpeed *= 0.8;

    player.z += currentSpeed * dt;
    addScore((currentSpeed * dt * 0.1).toInt());

    // Proximity check for 💋 KISS interaction
    eligibleKissTarget = null;
    for (final npc in npcs) {
      if (!npc.canBeKissed || npc.isKissed) continue;
      final dz = npc.z - player.z;
      // In front of player, within reach
      if (dz > 15 && dz < 95 && (npc.lane - player.currentLanePos).abs() < 0.85) {
        eligibleKissTarget = npc;
        break;
      }
    }
  }

  void _updateChaser(double dt) {
    if (!player.hasChaser) return;

    // If running smoothly, player slowly gains ground on pursuer
    if (!player.isStunned) {
      player.chaserDistance += 14.0 * dt;
      if (player.chaserDistance >= 110.0) {
        // Escaped!!
        player.hasChaser = false;
        escapeCount++;
        addScore(150);
        SaveManager.incrementEscapes();
        SoundManager.play(SoundType.cheer);
        activeEventBanner = 'ESCAPED PURSUER! +150 🏃💨';
        eventBannerTimer = 2.5;
      }
    }

    // If chaser distance reaches 0, caught!
    if (player.chaserDistance <= 0) {
      _triggerGameOver();
    }
  }

  void _checkCollisions() {
    if (player.isInvincible) return;

    for (final obs in obstacles) {
      if (obs.hasCollided) continue;

      final dz = (obs.z - player.z).abs();
      final inLane = (obs.lane - player.currentLanePos).abs() < 0.55;

      if (dz < 28 && inLane) {
        // Check if player evaded with Jump or Slide!
        if (obs.requiresJump && player.jumpY > 40) {
          // Successfully jumped over!
          continue;
        }
        if (obs.requiresSlide && player.isSliding) {
          // Successfully slid under!
          continue;
        }

        // Hit obstacle!
        obs.hasCollided = true;
        SoundManager.play(SoundType.slip);
        screenShake = 0.8;
        particleSystem.spawnStars(obs.lane * 100, 300);

        if (obs.type == ObstacleType.bananaPeel) {
          player.stunTimer = 0.6;
          floatingTexts.add(FloatingText3D(
            text: 'SLIPPED! 🍌',
            color: Colors.yellowAccent,
            lane: player.currentLanePos,
            z: player.z,
          ));
        } else {
          player.takeDamage(1);
          floatingTexts.add(FloatingText3D(
            text: 'OUCH! -1 ❤️',
            color: Colors.redAccent,
            lane: player.currentLanePos,
            z: player.z,
          ));
        }

        // Chaser gains ground!
        player.chaserDistance = (player.chaserDistance - 45).clamp(0.0, 100.0);

        if (player.health <= 0 || player.chaserDistance <= 0) {
          _triggerGameOver();
        }
        break;
      }
    }
  }

  void _checkCoinPickups() {
    for (final c in coins) {
      if (c.isCollected) continue;

      final dz = (c.z - player.z).abs();
      final inLane = (c.lane - player.currentLanePos).abs() < 0.65;
      final matchY = (c.y - player.jumpY).abs() < 45;

      // Magnet pulls coins from all lanes!
      if (player.hasMagnet && dz < 350) {
        c.lane += (player.currentLanePos - c.lane) * 0.15;
      }

      if (dz < 35 && inLane && matchY) {
        c.isCollected = true;
        runHeartCoins++;
        addScore(15 * combo);
        SaveManager.addHeartCoins(1);
        SoundManager.play(SoundType.coin);
      }
    }
  }

  void _checkPowerUpPickups() {
    for (final pu in powerUps) {
      if (pu.isCollected) continue;

      final dz = (pu.z - player.z).abs();
      final inLane = (pu.lane - player.currentLanePos).abs() < 0.7;

      if (dz < 40 && inLane) {
        pu.isCollected = true;
        SoundManager.play(SoundType.coin);
        particleSystem.spawnCoinSparkles(200, 300);

        floatingTexts.add(FloatingText3D(
          text: '${pu.iconEmoji} ${pu.name}!',
          color: Colors.amberAccent,
          lane: player.currentLanePos,
          z: player.z,
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
    }
  }

  void _updateChainReactions() {
    final events = _chainManager.processChaserCollisions(
      npcs: npcs,
      obstacles: obstacles,
      playerZ: player.z,
      hasChaser: player.hasChaser,
      chainChance: currentLevel.chainReactionChance * (player.isChaos ? 1.5 : 1.0),
    );

    for (final e in events) {
      chainReactionCount++;
      addScore(e.bonusPoints);
      SoundManager.play(SoundType.scream);
      screenShake = 0.5;

      floatingTexts.add(FloatingText3D(
        text: '🔥 CHAIN REACTION! +${e.bonusPoints}',
        color: Colors.deepOrangeAccent,
        lane: e.lane,
        z: e.z,
      ));

      activeEventBanner = 'STREET DOMINO CHAOS! 💥';
      eventBannerTimer = 2.0;
    }
  }

  /// The 💋 KISS Interaction in 3D Track!
  void performKiss() {
    final target = eligibleKissTarget;
    if (target == null || !target.canBeKissed) return;

    // Pick reaction
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
    comboTimer = 5.0;

    if (reaction.coinReward > 0) {
      runHeartCoins += reaction.coinReward;
      SaveManager.addHeartCoins(reaction.coinReward);
    }

    SoundManager.play(SoundType.kiss);
    particleSystem.spawnHearts(200, 300, count: 8);

    floatingTexts.add(FloatingText3D(
      text: '${reaction.emoji} ${reaction.name} +${reaction.scorePoints * combo}',
      color: reaction.category == ReactionCategory.positive ? Colors.pinkAccent : Colors.orangeAccent,
      lane: target.lane,
      z: target.z,
    ));

    _executeReactionConsequence(target, reaction);
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
        particleSystem.spawnAnger(200, 300);
        activeEventBanner = FunnyDialogues.getRandom(FunnyDialogues.slapped);
        eventBannerTimer = 2.5;
        // Immediate pursuit!
        player.hasChaser = true;
        player.chaserDistance = 45.0;
        player.chaserTypeId = npc.typeId;
        player.chaserName = npc.name;
        if (player.health <= 0) _triggerGameOver();
        break;

      case ConsequenceType.chasePlayer:
      case ConsequenceType.callFriends:
        player.hasChaser = true;
        player.chaserDistance = 60.0;
        player.chaserTypeId = npc.typeId;
        player.chaserName = npc.name;
        activeEventBanner = 'RUN! THEY ARE ON YOUR TAIL!! 🏃💨';
        eventBannerTimer = 2.5;
        SoundManager.play(SoundType.scream);
        break;

      case ConsequenceType.callPolice:
        player.hasChaser = true;
        player.chaserDistance = 50.0;
        player.chaserTypeId = 'police_officer';
        player.chaserName = 'Police Inspector';
        activeEventBanner = FunnyDialogues.getRandom(FunnyDialogues.policeAlert);
        eventBannerTimer = 3.0;
        SoundManager.play(SoundType.siren);
        break;

      default:
        break;
    }
  }

  // Swipe controls (Subway Surfers / Temple Run gestures)
  void swipeLeft() {
    player.switchLane(-1);
    SoundManager.play(SoundType.whoosh);
    notifyListeners();
  }

  void swipeRight() {
    player.switchLane(1);
    SoundManager.play(SoundType.whoosh);
    notifyListeners();
  }

  void swipeUp() {
    player.jump();
    SoundManager.play(SoundType.boing);
    notifyListeners();
  }

  void swipeDown() {
    player.slide();
    SoundManager.play(SoundType.whoosh);
    notifyListeners();
  }

  void addScore(int pts) {
    score += pts;
    if (score > SaveManager.getHighScore()) {
      SaveManager.saveHighScore(score);
    }
    if (combo > SaveManager.getBestCombo()) {
      SaveManager.saveBestCombo(combo);
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
    addScore(500);
    SaveManager.unlockLevel(currentLevel.levelNumber + 1);
    SaveManager.addHeartCoins(50);
    runHeartCoins += 50;
    notifyListeners();
  }

  void revivePlayer() {
    player.health = player.maxHealth;
    player.invincibilityTimer = 3.0;
    player.hasChaser = false;
    player.chaserDistance = 100.0;
    status = GameStatus.playing;
    notifyListeners();
  }

  void restartLevel() {
    _initLevel();
    notifyListeners();
  }
}
