import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../models/level_model.dart';
import '../../data/level_definitions.dart';
import '../../systems/game_controller.dart';
import '../../rendering/game_world_painter.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  final LevelModel level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late GameController _controller;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = GameController(level: widget.level);
    _controller.addListener(_onControllerUpdate);

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      // Cap delta time to prevent physics anomalies on frame drops
      final safeDt = dt.clamp(0.001, 0.05);
      _controller.update(safeDt);
    });

    _ticker.start();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _handlePause() {
    setState(() {
      _controller.status = GameStatus.paused;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'GAME PAUSED',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _controller.status = GameStatus.playing;
              });
            },
            child: const Text('RESUME', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('QUIT TO MENU', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen shake offset calculation
    double shakeX = 0;
    double shakeY = 0;
    if (_controller.screenShake > 0) {
      shakeX = (Random().nextDouble() * 2 - 1) * 8 * _controller.screenShake;
      shakeY = (Random().nextDouble() * 2 - 1) * 8 * _controller.screenShake;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Canvas rendering viewport with subtle screen shake
          Transform.translate(
            offset: Offset(shakeX, shakeY),
            child: CustomPaint(
              size: Size.infinite,
              painter: GameWorldPainter(
                player: _controller.player,
                npcs: _controller.npcs,
                obstacles: _controller.obstacles,
                powerUps: _controller.powerUps,
                level: _controller.currentLevel,
                particleSystem: _controller.particleSystem,
                floatingTexts: _controller.floatingTexts,
                cameraX: _controller.cameraX,
                animTime: _controller.animTime,
              ),
            ),
          ),

          // Heads-up Display (HUD)
          GameHUD(
            controller: _controller,
            onPause: _handlePause,
          ),

          // Game Over Screen Modal
          if (_controller.status == GameStatus.gameOver)
            Container(
              color: Colors.black54,
              child: GameOverDialog(
                controller: _controller,
                onHome: () => Navigator.pop(context),
              ),
            ),

          // Level Complete Modal
          if (_controller.status == GameStatus.levelComplete)
            Container(
              color: Colors.black54,
              child: VictoryDialog(
                controller: _controller,
                onNextLevel: () {
                  final nextNum = widget.level.levelNumber + 1;
                  final nextLevel = LevelDefinitions.getByNumber(nextNum);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => GameScreen(level: nextLevel),
                    ),
                  );
                },
                onHome: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}
