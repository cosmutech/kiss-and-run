import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../models/npc_model.dart';
import '../models/obstacle_model.dart';
import '../models/powerup_model.dart';
import '../models/level_model.dart';
import 'character_painter.dart';
import 'particle_system.dart';

class FloatingText {
  final String text;
  final Color color;
  double x;
  double y;
  double life;
  final double maxLife;

  FloatingText({
    required this.text,
    required this.color,
    required this.x,
    required this.y,
    this.life = 0.0,
    this.maxLife = 1.2,
  });

  bool get isDead => life >= maxLife;
}

class GameWorldPainter extends CustomPainter {
  final PlayerModel player;
  final List<NPCModel> npcs;
  final List<ObstacleModel> obstacles;
  final List<PowerUpModel> powerUps;
  final LevelModel level;
  final ParticleSystem particleSystem;
  final List<FloatingText> floatingTexts;
  final double cameraX;
  final double animTime;

  GameWorldPainter({
    required this.player,
    required this.npcs,
    required this.obstacles,
    required this.powerUps,
    required this.level,
    required this.particleSystem,
    required this.floatingTexts,
    required this.cameraX,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Translate canvas according to camera position
    canvas.translate(-cameraX, 0);

    // 1. Draw World Background & Scenery
    _drawEnvironment(canvas, size);

    // 2. Draw Finish Gate / Target Line (if not endless)
    if (!level.isEndless) {
      _drawFinishLine(canvas, size);
    }

    // 3. Draw Obstacles
    _drawObstacles(canvas);

    // 4. Draw Power-Ups
    _drawPowerUps(canvas);

    // 5. Draw NPCs
    for (final npc in npcs) {
      final isMoving = npc.vx.abs() > 5 || npc.vy.abs() > 5;
      final isLove = npc.activeReaction?.id == 'love' || npc.activeReaction?.id == 'kiss_back';
      final isAngry = npc.isChasing;

      CharacterPainter.drawCharacter(
        canvas: canvas,
        x: npc.x,
        y: npc.y,
        facingDirection: npc.facingDirection,
        skinTone: npc.skinTone,
        hairColor: npc.hairColor,
        hairStyle: 0,
        shirtColor: npc.shirtColor,
        pantsColor: npc.pantsColor,
        accessoryIndex: 0,
        isKissing: false,
        isSlapped: false,
        isLove: isLove,
        isAngry: isAngry,
        isMoving: isMoving,
        animTime: animTime,
      );

      // Speech bubble if active
      if (npc.speechBubble != null && npc.speechBubbleTimer > 0) {
        CharacterPainter.drawSpeechBubble(
          canvas: canvas,
          x: npc.x,
          y: npc.y,
          text: npc.speechBubble!,
        );
      }
    }

    // 6. Draw Player
    _drawPlayer(canvas);

    // 7. Draw Particles
    _drawParticles(canvas);

    // 8. Draw Floating Comic & Score Texts
    _drawFloatingTexts(canvas);

    canvas.restore();
  }

  void _drawEnvironment(Canvas canvas, Size size) {
    final worldWidth = level.isEndless ? cameraX + size.width + 1000 : level.worldLength;

    // Sky / Upper Wall
    final skyPaint = Paint()..color = level.groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, 220), skyPaint);

    // Backdrop City Scenery (Parallax storefronts, trees, benches)
    final sceneryPaint = Paint()..color = level.accentColor.withOpacity(0.18);
    for (double x = 0; x < worldWidth; x += 180) {
      if (level.environmentTheme == 'park') {
        // Draw cartoon trees
        final trunkPaint = Paint()..color = const Color(0xFF795548);
        canvas.drawRect(Rect.fromLTWH(x + 20, 140, 14, 50), trunkPaint);
        final foliagePaint = Paint()..color = const Color(0xFF66BB6A);
        canvas.drawCircle(Offset(x + 27, 130), 28, foliagePaint);
      } else if (level.environmentTheme == 'beach') {
        // Draw umbrellas
        final polePaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(x + 30, 140, 6, 50), polePaint);
        final umbrellaPaint = Paint()..color = Colors.orangeAccent;
        canvas.drawArc(Rect.fromCircle(center: Offset(x + 33, 140), radius: 26), pi, pi, true, umbrellaPaint);
      } else {
        // Storefront / Building silhouettes
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 10, 80 + (sin(x) * 20), 140, 110),
            const Radius.circular(8),
          ),
          sceneryPaint,
        );
      }
    }

    // Sidewalk
    final sidewalkPaint = Paint()..color = const Color(0xFFD6DBDF);
    canvas.drawRect(Rect.fromLTWH(0, 190, worldWidth, 180), sidewalkPaint);

    // Paving lines
    final tilePaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 2.0;
    for (double x = 0; x < worldWidth; x += 60) {
      canvas.drawLine(Offset(x, 190), Offset(x, 370), tilePaint);
    }
    canvas.drawLine(const Offset(0, 280), Offset(worldWidth, 280), tilePaint);

    // Road Curb
    final curbPaint = Paint()..color = const Color(0xFFBDC3C7);
    canvas.drawRect(Rect.fromLTWH(0, 370, worldWidth, 18), curbPaint);

    // Road (Asphalt)
    final roadPaint = Paint()..color = level.roadColor;
    canvas.drawRect(Rect.fromLTWH(0, 388, worldWidth, size.height - 388), roadPaint);

    // Dashed Road Striping
    final dashPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    for (double x = 0; x < worldWidth; x += 50) {
      canvas.drawLine(Offset(x, 480), Offset(x + 25, 480), dashPaint);
    }
  }

  void _drawFinishLine(Canvas canvas, Size size) {
    final x = level.worldLength - 150;
    // Checkered banner
    final postPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 8.0;
    canvas.drawLine(Offset(x, 180), Offset(x, 560), postPaint);

    final bannerPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    for (int r = 0; r < 12; r++) {
      final y = 200.0 + (r * 28);
      canvas.drawRect(Rect.fromLTWH(x - 8, y, 16, 14), (r % 2 == 0) ? bannerPaint : whitePaint);
    }

    // Finish Text
    final tp = TextPainter(
      text: const TextSpan(
        text: '🏁 ESCAPE GOAL 🏁',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - 60, 160));
  }

  void _drawObstacles(Canvas canvas) {
    for (final obs in obstacles) {
      final tp = TextPainter(
        text: TextSpan(
          text: obs.emoji,
          style: const TextStyle(fontSize: 26),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Shadow
      final sPaint = Paint()..color = Colors.black26;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(obs.x + 13, obs.y + 24), width: 26, height: 10),
        sPaint,
      );

      tp.paint(canvas, Offset(obs.x, obs.y));
    }
  }

  void _drawPowerUps(Canvas canvas) {
    for (final pu in powerUps) {
      if (pu.isCollected) continue;
      final bounce = sin(animTime * 6) * 6;

      // Glow halo
      final glowPaint = Paint()
        ..color = Colors.yellowAccent.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(pu.x + 15, pu.y + 15 + bounce), 24, glowPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: pu.iconEmoji,
          style: const TextStyle(fontSize: 28),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(pu.x, pu.y + bounce));
    }
  }

  void _drawPlayer(Canvas canvas) {
    final isMoving = player.vx.abs() > 5 || player.vy.abs() > 5;
    final isKissing = player.state == PlayerState.kissing;
    final isSlapped = player.state == PlayerState.slapped;

    // Shield Aura
    if (player.hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(Offset(player.x, player.y), 36, shieldPaint);
    }

    // Angel Halo Glow
    if (player.isAngel) {
      final angelPaint = Paint()
        ..color = Colors.amber.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(Offset(player.x, player.y), 40, angelPaint);
    }

    // Speed Boost trail
    if (player.hasSpeedBoost) {
      final trailPaint = Paint()..color = Colors.orangeAccent.withOpacity(0.3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(player.x - (player.facingDirection * 20), player.y + 10),
          width: 25,
          height: 35,
        ),
        trailPaint,
      );
    }

    // Color choices
    final skinColors = [
      const Color(0xFFFFDFC4),
      const Color(0xFFE0AC69),
      const Color(0xFFC68642),
      const Color(0xFF8D5524),
    ];
    final hairColors = [
      const Color(0xFF424242),
      const Color(0xFFFFD54F),
      const Color(0xFF8D6E63),
      const Color(0xFFD32F2F),
    ];
    final shirtColors = [
      const Color(0xFFFF4081),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFF212121),
      const Color(0xFFFFD700),
    ];
    final pantsColors = [
      const Color(0xFF1976D2),
      const Color(0xFF263238),
      const Color(0xFFD7CCC8),
    ];

    final skin = skinColors[player.skinToneIndex.clamp(0, skinColors.length - 1)];
    final hair = hairColors[player.hairColorIndex.clamp(0, hairColors.length - 1)];
    final shirt = shirtColors[player.shirtColorIndex.clamp(0, shirtColors.length - 1)];
    final pants = pantsColors[player.pantsColorIndex.clamp(0, pantsColors.length - 1)];

    // Vertical Jump Offset
    final jumpY = player.isJumping ? -sin(player.jumpProgress * pi) * 45 : 0.0;

    CharacterPainter.drawCharacter(
      canvas: canvas,
      x: player.x,
      y: player.y + jumpY,
      facingDirection: player.facingDirection,
      skinTone: skin,
      hairColor: hair,
      hairStyle: player.hairStyleIndex,
      shirtColor: shirt,
      pantsColor: pants,
      accessoryIndex: player.accessoryIndex,
      isKissing: isKissing,
      isSlapped: isSlapped,
      isLove: false,
      isAngry: false,
      isMoving: isMoving,
      animTime: animTime,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particleSystem.particles) {
      if (p.emoji != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: p.emoji,
            style: TextStyle(
              fontSize: p.size,
              color: Colors.white.withOpacity(p.alpha),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.x, p.y));
      } else {
        final pPaint = Paint()..color = p.color.withOpacity(p.alpha);
        canvas.drawCircle(Offset(p.x, p.y), p.size / 2, pPaint);
      }
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in floatingTexts) {
      final alpha = (1.0 - (ft.life / ft.maxLife)).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: ft.text,
          style: TextStyle(
            color: ft.color.withOpacity(alpha),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(ft.x, ft.y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
