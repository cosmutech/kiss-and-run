import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../models/npc_model.dart';
import '../models/obstacle_model.dart';
import '../models/powerup_model.dart';
import '../models/level_model.dart';
import 'particle_system.dart';

class FloatingText3D {
  final String text;
  final Color color;
  double lane;
  double z;
  double y;
  double life;
  final double maxLife;

  FloatingText3D({
    required this.text,
    required this.color,
    required this.lane,
    required this.z,
    this.y = 80.0,
    this.life = 0.0,
    this.maxLife = 1.3,
  });

  bool get isDead => life >= maxLife;
}

class GameWorld3DPainter extends CustomPainter {
  final PlayerModel player;
  final List<NPCModel> npcs;
  final List<ObstacleModel> obstacles;
  final List<HeartCoinModel> coins;
  final List<PowerUpModel> powerUps;
  final LevelModel level;
  final ParticleSystem particleSystem;
  final List<FloatingText3D> floatingTexts;
  final double animTime;

  GameWorld3DPainter({
    required this.player,
    required this.npcs,
    required this.obstacles,
    required this.coins,
    required this.powerUps,
    required this.level,
    required this.particleSystem,
    required this.floatingTexts,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.28;
    final centerX = size.width * 0.5;
    final trackWidthBottom = size.width * 0.88;
    final trackWidthTop = size.width * 0.12;

    // 1. Draw Sky & Parallax Skyline
    _drawSkyAndHorizon(canvas, size, horizonY);

    // 2. Draw 3-Lane 3D Road Perspective
    _draw3DTrack(canvas, size, horizonY, centerX, trackWidthBottom, trackWidthTop);

    // 3. Draw Side Props (Street lamps / palm trees scrolling in 3D)
    _drawSideScenery(canvas, size, horizonY, centerX);

    // 4. Sort all 3D entities by distance Z (back to front) for perfect depth sorting!
    final renderList = <_RenderItem>[];

    // Coins
    for (final c in coins) {
      if (!c.isCollected && c.z >= player.z - 40 && c.z <= player.z + 1200) {
        renderList.add(_RenderItem(z: c.z, type: _ItemType.coin, data: c));
      }
    }

    // Powerups
    for (final pu in powerUps) {
      if (!pu.isCollected && pu.z >= player.z - 40 && pu.z <= player.z + 1200) {
        renderList.add(_RenderItem(z: pu.z, type: _ItemType.powerUp, data: pu));
      }
    }

    // Obstacles
    for (final obs in obstacles) {
      if (obs.z >= player.z - 40 && obs.z <= player.z + 1200) {
        renderList.add(_RenderItem(z: obs.z, type: _ItemType.obstacle, data: obs));
      }
    }

    // NPCs
    for (final npc in npcs) {
      if (npc.z >= player.z - 60 && npc.z <= player.z + 1200) {
        renderList.add(_RenderItem(z: npc.z, type: _ItemType.npc, data: npc));
      }
    }

    // Chaser (running right behind player!)
    if (player.hasChaser) {
      final chaserZ = player.z - (player.chaserDistance * 0.65);
      renderList.add(_RenderItem(z: chaserZ, type: _ItemType.chaser, data: null));
    }

    // Player
    renderList.add(_RenderItem(z: player.z, type: _ItemType.player, data: null));

    // Sort descending by Z so farthest is drawn first
    renderList.sort((a, b) => b.z.compareTo(a.z));

    // Render sorted entities in 3D
    for (final item in renderList) {
      switch (item.type) {
        case _ItemType.coin:
          _drawCoin3D(canvas, size, horizonY, centerX, item.data as HeartCoinModel);
          break;
        case _ItemType.powerUp:
          _drawPowerUp3D(canvas, size, horizonY, centerX, item.data as PowerUpModel);
          break;
        case _ItemType.obstacle:
          _drawObstacle3D(canvas, size, horizonY, centerX, item.data as ObstacleModel);
          break;
        case _ItemType.npc:
          _drawNPC3D(canvas, size, horizonY, centerX, item.data as NPCModel);
          break;
        case _ItemType.chaser:
          _drawChaser3D(canvas, size, horizonY, centerX);
          break;
        case _ItemType.player:
          _drawPlayer3D(canvas, size, horizonY, centerX);
          break;
      }
    }

    // 5. Draw 3D Floating Texts
    _drawFloatingTexts(canvas, size, horizonY, centerX);

    // 6. Draw 2D Screen Particles (Hearts, sparkles, speed lines)
    _drawScreenParticles(canvas, size);

    // 7. Chaser Warning Vignette if breathing down your neck
    if (player.hasChaser && player.chaserDistance < 35) {
      final pulse = (sin(animTime * 12) + 1) * 0.5;
      final vignettePaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.25 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
    }
  }

  // Helper 3D Projection Formula
  Offset _project(double lane, double z, double y, Size size, double horizonY, double centerX) {
    final dz = z - player.z;
    // Scale factor based on depth distance
    final scale = 1.0 / (1.0 + (dz + 60) * 0.0028);
    final laneWidth = size.width * 0.28;

    final screenX = centerX + (lane * laneWidth * scale);
    final trackBottomY = size.height * 0.88;
    final screenY = horizonY + (trackBottomY - horizonY) * scale - (y * scale);

    return Offset(screenX, screenY);
  }

  double _getScale(double z) {
    final dz = z - player.z;
    return (1.0 / (1.0 + (dz + 60) * 0.0028)).clamp(0.05, 2.5);
  }

  void _drawSkyAndHorizon(Canvas canvas, Size size, double horizonY) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        colors: [level.groundColor, const Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY), skyPaint);

    // Distant City Skyline Silhouette
    final cityPaint = Paint()..color = level.roadColor.withOpacity(0.4);
    for (double x = 0; x < size.width; x += 35) {
      final h = 30 + sin(x * 0.1) * 20;
      canvas.drawRect(Rect.fromLTWH(x, horizonY - h, 28, h), cityPaint);
    }

    // Horizon line glow
    final glowPaint = Paint()
      ..color = level.accentColor.withOpacity(0.5)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(0, horizonY), Offset(size.width, horizonY), glowPaint);
  }

  void _draw3DTrack(Canvas canvas, Size size, double horizonY, double centerX, double trackWidthBottom, double trackWidthTop) {
    final trackBottomY = size.height;

    // 3D Road Trapezoid
    final roadPath = Path();
    roadPath.moveTo(centerX - trackWidthTop / 2, horizonY);
    roadPath.lineTo(centerX + trackWidthTop / 2, horizonY);
    roadPath.lineTo(centerX + trackWidthBottom / 2, trackBottomY);
    roadPath.lineTo(centerX - trackWidthBottom / 2, trackBottomY);
    roadPath.close();

    final roadPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawPath(roadPath, roadPaint);

    // Left and Right Curbs / Sidewalks (Subway Surfers red/white curb tiles)
    final curbPaint = Paint()
      ..color = level.accentColor
      ..strokeWidth = 6.0;
    canvas.drawLine(Offset(centerX - trackWidthTop / 2, horizonY), Offset(centerX - trackWidthBottom / 2, trackBottomY), curbPaint);
    canvas.drawLine(Offset(centerX + trackWidthTop / 2, horizonY), Offset(centerX + trackWidthBottom / 2, trackBottomY), curbPaint);

    // 3 Lanes Dividers (recalls Outrun / Subway Surfers perspective dashed stripes)
    final stripePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3.5;

    // Calculate dashed road markings scrolling with player.z
    final scrollOffset = (player.z % 160);

    for (double z = 0; z < 1000; z += 80) {
      final markZ = player.z + z - scrollOffset;
      if (markZ < player.z - 40) continue;

      final p1 = _project(-0.33, markZ, 0, size, horizonY, centerX);
      final p2 = _project(-0.33, markZ + 35, 0, size, horizonY, centerX);
      final p3 = _project(0.33, markZ, 0, size, horizonY, centerX);
      final p4 = _project(0.33, markZ + 35, 0, size, horizonY, centerX);

      canvas.drawLine(p1, p2, stripePaint);
      canvas.drawLine(p3, p4, stripePaint);
    }
  }

  void _drawSideScenery(Canvas canvas, Size size, double horizonY, double centerX) {
    // Street lamps and trees rushing past on the sidewalks
    final scrollOffset = (player.z % 240);

    for (double z = 0; z < 1100; z += 160) {
      final propZ = player.z + z - scrollOffset;
      if (propZ < player.z - 40) continue;

      final scale = _getScale(propZ);

      // Left sidewalk lamp/prop
      final leftPos = _project(-1.8, propZ, 0, size, horizonY, centerX);
      // Right sidewalk lamp/prop
      final rightPos = _project(1.8, propZ, 0, size, horizonY, centerX);

      final postPaint = Paint()
        ..color = Colors.grey.shade800
        ..strokeWidth = 4.0 * scale;

      // Lamp posts
      canvas.drawLine(leftPos, Offset(leftPos.dx, leftPos.dy - 75 * scale), postPaint);
      canvas.drawLine(rightPos, Offset(rightPos.dx, rightPos.dy - 75 * scale), postPaint);

      // Glowing light bulbs
      final bulbPaint = Paint()..color = Colors.amberAccent;
      canvas.drawCircle(Offset(leftPos.dx, leftPos.dy - 75 * scale), 7 * scale, bulbPaint);
      canvas.drawCircle(Offset(rightPos.dx, rightPos.dy - 75 * scale), 7 * scale, bulbPaint);
    }
  }

  void _drawPlayer3D(Canvas canvas, Size size, double horizonY, double centerX) {
    final pos = _project(player.currentLanePos, player.z, player.jumpY, size, horizonY, centerX);
    final scale = _getScale(player.z);

    // Ground Drop Shadow (stays on the road, shrinks as jump gets higher!)
    final groundPos = _project(player.currentLanePos, player.z, 0, size, horizonY, centerX);
    final shadowScale = (1.0 - (player.jumpY / 180.0)).clamp(0.3, 1.0);

    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(groundPos.dx, groundPos.dy + 12 * scale),
        width: 48 * scale * shadowScale,
        height: 16 * scale * shadowScale,
      ),
      shadowPaint,
    );

    // Tilt angle when switching lanes (Subway Surfers dynamic banking!)
    final laneDelta = player.targetLane - player.currentLanePos;
    final tiltAngle = laneDelta * 0.18;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(tiltAngle);

    // Shield Aura
    if (player.hasShield) {
      final sPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * scale;
      canvas.drawCircle(Offset(0, -30 * scale), 46 * scale, sPaint);
    }

    // Magnet Aura
    if (player.hasMagnet) {
      final mPaint = Paint()
        ..color = Colors.yellowAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * scale;
      canvas.drawCircle(Offset(0, -30 * scale), 52 * scale, mPaint);
    }

    // Draw Character from Behind (Running back view)
    _drawCharacterFromBehind(
      canvas: canvas,
      scale: scale * 1.3,
      shirtColor: _getShirtColor(),
      pantsColor: _getPantsColor(),
      hairColor: _getHairColor(),
      hairStyle: player.hairStyleIndex,
      accessoryIndex: player.accessoryIndex,
      isSliding: player.isSliding,
      animTime: animTime,
    );

    canvas.restore();
  }

  void _drawChaser3D(Canvas canvas, Size size, double horizonY, double centerX) {
    // Chaser runs behind the player
    final chaserZ = player.z - (player.chaserDistance * 0.65);
    final pos = _project(player.currentLanePos * 0.8, chaserZ, 0, size, horizonY, centerX);
    final scale = _getScale(chaserZ);

    // Shadow
    final sPaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 10 * scale), width: 44 * scale, height: 14 * scale),
      sPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // Draw angry pursuer / police officer
    final isPolice = player.chaserTypeId == 'police_officer';
    final outfitColor = isPolice ? const Color(0xFF1565C0) : const Color(0xFFD32F2F);

    _drawCharacterFromBehind(
      canvas: canvas,
      scale: scale * 1.25,
      shirtColor: outfitColor,
      pantsColor: const Color(0xFF212121),
      hairColor: const Color(0xFF212121),
      hairStyle: 0,
      accessoryIndex: isPolice ? 2 : 0,
      isSliding: false,
      animTime: animTime * 1.2,
      isAngryChaser: true,
    );

    // Warning / Anger exclamation above head
    final tp = TextPainter(
      text: TextSpan(
        text: isPolice ? '🚨' : '💢',
        style: TextStyle(fontSize: 22 * scale),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-12 * scale, -75 * scale));

    canvas.restore();
  }

  void _drawNPC3D(Canvas canvas, Size size, double horizonY, double centerX, NPCModel npc) {
    final pos = _project(npc.lane, npc.z, 0, size, horizonY, centerX);
    final scale = _getScale(npc.z);

    // Shadow
    final sPaint = Paint()..color = Colors.black26;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 8 * scale), width: 38 * scale, height: 12 * scale),
      sPaint,
    );

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    // If eligible for kiss, draw pulsing neon heart halo under their feet!
    final distToPlayer = (npc.z - player.z).abs();
    final isNearby = distToPlayer < 90 && (npc.lane - player.currentLanePos).abs() < 0.9;

    if (isNearby && npc.canBeKissed) {
      final pulse = (sin(animTime * 10) + 1) * 0.5;
      final haloPaint = Paint()
        ..color = Colors.pinkAccent.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4 + pulse * 3) * scale;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, 8 * scale), width: 55 * scale, height: 22 * scale),
        haloPaint,
      );

      // Kiss prompt icon
      final kissIcon = TextPainter(
        text: TextSpan(text: '💋', style: TextStyle(fontSize: 24 * scale)),
        textDirection: TextDirection.ltr,
      )..layout();
      kissIcon.paint(canvas, Offset(-12 * scale, -80 * scale));
    }

    // NPC facing player (Front view)
    _drawCharacterFront(
      canvas: canvas,
      scale: scale * 1.2,
      shirtColor: npc.shirtColor,
      pantsColor: npc.pantsColor,
      hairColor: npc.hairColor,
      skinTone: npc.skinTone,
      isKissed: npc.isKissed,
    );

    // Comic speech bubble
    if (npc.speechBubble != null && npc.speechBubbleTimer > 0) {
      final bubbleTp = TextPainter(
        text: TextSpan(
          text: npc.speechBubble!,
          style: TextStyle(
            color: Colors.black87,
            fontSize: (11 * scale).clamp(9.0, 16.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 140 * scale);

      final bubbleRect = Rect.fromCenter(
        center: Offset(0, -70 * scale),
        width: bubbleTp.width + 14,
        height: bubbleTp.height + 8,
      );
      final bPaint = Paint()..color = Colors.white;
      final strokePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(8)), bPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(8)), strokePaint);
      bubbleTp.paint(canvas, Offset(bubbleRect.left + 7, bubbleRect.top + 4));
    }

    canvas.restore();
  }

  void _drawObstacle3D(Canvas canvas, Size size, double horizonY, double centerX, ObstacleModel obs) {
    final pos = _project(obs.lane, obs.z, 0, size, horizonY, centerX);
    final scale = _getScale(obs.z);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    if (obs.type == ObstacleType.roadblockLow) {
      // 3D Low Hurdle (Must JUMP over!)
      final hurdlePaint = Paint()..color = Colors.redAccent;
      final whiteStripe = Paint()..color = Colors.white;

      final w = 55 * scale;
      final h = 26 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -h / 2), width: w, height: h), const Radius.circular(4)),
        hurdlePaint,
      );
      // Stripes
      canvas.drawRect(Rect.fromLTWH(-w * 0.3, -h, w * 0.2, h), whiteStripe);
      canvas.drawRect(Rect.fromLTWH(w * 0.1, -h, w * 0.2, h), whiteStripe);

      // Jump hint icon
      final tp = TextPainter(
        text: TextSpan(text: '▲ JUMP', style: TextStyle(color: Colors.yellowAccent, fontSize: 10 * scale, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -h - 14 * scale));
    } else if (obs.type == ObstacleType.overheadBarrier) {
      // 3D High Overhead Barrier (Must SLIDE under!)
      final pipePaint = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 5 * scale;
      // Two vertical posts
      canvas.drawLine(Offset(-32 * scale, 0), Offset(-32 * scale, -55 * scale), pipePaint);
      canvas.drawLine(Offset(32 * scale, 0), Offset(32 * scale, -55 * scale), pipePaint);

      // Top sign
      final signPaint = Paint()..color = Colors.amber;
      canvas.drawRect(Rect.fromLTWH(-36 * scale, -55 * scale, 72 * scale, 18 * scale), signPaint);

      // Slide hint icon
      final tp = TextPainter(
        text: TextSpan(text: '▼ SLIDE', style: TextStyle(color: Colors.black87, fontSize: 10 * scale, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -52 * scale));
    } else {
      // Emoji based hazard (Banana peel / Food cart)
      final tp = TextPainter(
        text: TextSpan(text: obs.emoji, style: TextStyle(fontSize: 32 * scale)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height));
    }

    canvas.restore();
  }

  void _drawCoin3D(Canvas canvas, Size size, double horizonY, double centerX, HeartCoinModel coin) {
    final pos = _project(coin.lane, coin.z, coin.y, size, horizonY, centerX);
    final scale = _getScale(coin.z);

    // 3D Rotating Heart Coin
    final spin = cos(animTime * 6 + coin.z);
    final coinWidth = (22 * scale * spin.abs()).clamp(3.0, 30.0);

    final coinPaint = Paint()..color = Colors.pinkAccent;
    final borderPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 16 * scale), width: coinWidth, height: 22 * scale),
      coinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 16 * scale), width: coinWidth, height: 22 * scale),
      borderPaint,
    );
  }

  void _drawPowerUp3D(Canvas canvas, Size size, double horizonY, double centerX, PowerUpModel pu) {
    final bounce = sin(animTime * 6) * 10;
    final pos = _project(pu.lane, pu.z, pu.y + bounce, size, horizonY, centerX);
    final scale = _getScale(pu.z);

    // Glowing 3D Orb
    final glowPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale);
    canvas.drawCircle(Offset(pos.dx, pos.dy - 20 * scale), 24 * scale, glowPaint);

    final tp = TextPainter(
      text: TextSpan(text: pu.iconEmoji, style: TextStyle(fontSize: 32 * scale)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 20 * scale - tp.height / 2));
  }

  // Draw Subway Surfers / Temple Run runner viewed from behind!
  void _drawCharacterFromBehind({
    required Canvas canvas,
    required double scale,
    required Color shirtColor,
    required Color pantsColor,
    required Color hairColor,
    required int hairStyle,
    required int accessoryIndex,
    required bool isSliding,
    required double animTime,
    bool isAngryChaser = false,
  }) {
    if (isSliding) {
      // Ducking slide pose!
      final bodyPaint = Paint()..color = shirtColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -12 * scale), width: 34 * scale, height: 18 * scale), Radius.circular(8 * scale)),
        bodyPaint,
      );
      // Head low
      final headPaint = Paint()..color = const Color(0xFFFFDFC4);
      canvas.drawCircle(Offset(10 * scale, -12 * scale), 12 * scale, headPaint);
      // Dust clouds behind
      final dustPaint = Paint()..color = Colors.white60;
      canvas.drawCircle(Offset(-16 * scale, 0), 8 * scale, dustPaint);
      canvas.drawCircle(Offset(-24 * scale, -3 * scale), 6 * scale, dustPaint);
      return;
    }

    final runCycle = sin(animTime * 14);

    // 1. Animated Legs from Behind
    final legPaint = Paint()
      ..color = pantsColor
      ..strokeWidth = 8.0 * scale
      ..strokeCap = StrokeCap.round;

    // Left leg
    canvas.drawLine(
      Offset(-7 * scale, -10 * scale),
      Offset(-7 * scale, 12 * scale + (runCycle * 10 * scale)),
      legPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(7 * scale, -10 * scale),
      Offset(7 * scale, 12 * scale - (runCycle * 10 * scale)),
      legPaint,
    );

    // Shoes
    final shoePaint = Paint()..color = const Color(0xFF111111);
    canvas.drawCircle(Offset(-7 * scale, 14 * scale + (runCycle * 10 * scale)), 5.5 * scale, shoePaint);
    canvas.drawCircle(Offset(7 * scale, 14 * scale - (runCycle * 10 * scale)), 5.5 * scale, shoePaint);

    // 2. Torso / Shirt (Back view)
    final shirtPaint = Paint()..color = shirtColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -22 * scale), width: 30 * scale, height: 26 * scale), Radius.circular(8 * scale)),
      shirtPaint,
    );

    // 3. Pumping Arms
    final armPaint = Paint()
      ..color = shirtColor
      ..strokeWidth = 7.0 * scale
      ..strokeCap = StrokeCap.round;

    if (isAngryChaser) {
      // Fist shaking high!
      canvas.drawLine(Offset(-12 * scale, -24 * scale), Offset(-18 * scale, -42 * scale), armPaint);
      canvas.drawLine(Offset(12 * scale, -24 * scale), Offset(18 * scale, -12 * scale), armPaint);
    } else {
      // Natural running arm pump
      canvas.drawLine(Offset(-12 * scale, -24 * scale), Offset(-16 * scale, -10 * scale + (runCycle * 10 * scale)), armPaint);
      canvas.drawLine(Offset(12 * scale, -24 * scale), Offset(16 * scale, -10 * scale - (runCycle * 10 * scale)), armPaint);
    }

    // 4. Head & Hair from Behind
    final headPaint = Paint()..color = const Color(0xFFFFDFC4);
    canvas.drawCircle(Offset(0, -42 * scale), 16 * scale, headPaint);

    // Hair from behind
    final hPaint = Paint()..color = hairColor;
    canvas.drawCircle(Offset(0, -45 * scale), 16 * scale, hPaint);

    // 5. Accessories from behind
    if (accessoryIndex == 2) {
      // Backward Cap (Red bill facing back)
      final capPaint = Paint()..color = Colors.deepOrange;
      canvas.drawCircle(Offset(0, -46 * scale), 15 * scale, capPaint);
      canvas.drawRect(Rect.fromLTWH(-8 * scale, -40 * scale, 16 * scale, 6 * scale), capPaint);
    } else if (accessoryIndex == 3) {
      // DJ Headphones headband
      final hpPaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 4.0 * scale
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: Offset(0, -42 * scale), radius: 17 * scale), pi, pi, false, hpPaint);
    } else if (accessoryIndex == 5) {
      // Golden Angel Halo
      final haloPaint = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * scale;
      canvas.drawOval(Rect.fromCenter(center: Offset(0, -64 * scale), width: 30 * scale, height: 10 * scale), haloPaint);
    }
  }

  // Draw NPC facing forward
  void _drawCharacterFront({
    required Canvas canvas,
    required double scale,
    required Color shirtColor,
    required Color pantsColor,
    required Color hairColor,
    required Color skinTone,
    required bool isKissed,
  }) {
    // Body
    final shirtPaint = Paint()..color = shirtColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -20 * scale), width: 26 * scale, height: 24 * scale), Radius.circular(6 * scale)),
      shirtPaint,
    );
    // Legs
    final legPaint = Paint()
      ..color = pantsColor
      ..strokeWidth = 6.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-6 * scale, -8 * scale), Offset(-6 * scale, 12 * scale), legPaint);
    canvas.drawLine(Offset(6 * scale, -8 * scale), Offset(6 * scale, 12 * scale), legPaint);

    // Head
    final headPaint = Paint()..color = skinTone;
    canvas.drawCircle(Offset(0, -38 * scale), 15 * scale, headPaint);

    // Hair
    final hPaint = Paint()..color = hairColor;
    canvas.drawArc(Rect.fromCenter(center: Offset(0, -43 * scale), width: 30 * scale, height: 16 * scale), pi, pi, true, hPaint);

    // Face features
    if (isKissed) {
      // Blushing & Heart eyes
      final bPaint = Paint()..color = Colors.pinkAccent.withOpacity(0.5);
      canvas.drawCircle(Offset(-6 * scale, -34 * scale), 4 * scale, bPaint);
      canvas.drawCircle(Offset(6 * scale, -34 * scale), 4 * scale, bPaint);
      final tp = TextPainter(
        text: TextSpan(text: '😍', style: TextStyle(fontSize: 16 * scale)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-8 * scale, -45 * scale));
    } else {
      // Normal eyes & smile
      final eyePaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(-5 * scale, -38 * scale), 2.2 * scale, eyePaint);
      canvas.drawCircle(Offset(5 * scale, -38 * scale), 2.2 * scale, eyePaint);
    }
  }

  void _drawFloatingTexts(Canvas canvas, Size size, double horizonY, double centerX) {
    for (final ft in floatingTexts) {
      final pos = _project(ft.lane, ft.z, ft.y, size, horizonY, centerX);
      final scale = _getScale(ft.z);
      final alpha = (1.0 - (ft.life / ft.maxLife)).clamp(0.0, 1.0);

      final tp = TextPainter(
        text: TextSpan(
          text: ft.text,
          style: TextStyle(
            color: ft.color.withOpacity(alpha),
            fontSize: (18 * scale).clamp(12.0, 32.0),
            fontWeight: FontWeight.w900,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
    }
  }

  void _drawScreenParticles(Canvas canvas, Size size) {
    for (final p in particleSystem.particles) {
      if (p.emoji != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: p.emoji,
            style: TextStyle(fontSize: p.size, color: Colors.white.withOpacity(p.alpha)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.x, p.y));
      }
    }
  }

  Color _getShirtColor() {
    final shirtColors = [
      const Color(0xFFFF4081),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFF212121),
      const Color(0xFFFFD700),
    ];
    return shirtColors[player.shirtColorIndex.clamp(0, shirtColors.length - 1)];
  }

  Color _getPantsColor() {
    final pantsColors = [
      const Color(0xFF1976D2),
      const Color(0xFF263238),
      const Color(0xFFD7CCC8),
    ];
    return pantsColors[player.pantsColorIndex.clamp(0, pantsColors.length - 1)];
  }

  Color _getHairColor() {
    final hairColors = [
      const Color(0xFF424242),
      const Color(0xFFFFD54F),
      const Color(0xFF8D6E63),
      const Color(0xFFD32F2F),
    ];
    return hairColors[player.hairColorIndex.clamp(0, hairColors.length - 1)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum _ItemType { coin, powerUp, obstacle, npc, chaser, player }

class _RenderItem {
  final double z;
  final _ItemType type;
  final dynamic data;

  _RenderItem({required this.z, required this.type, required this.data});
}
