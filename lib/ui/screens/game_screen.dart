import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../models/level_model.dart';
import '../../data/level_definitions.dart';
import '../../systems/game_controller.dart';
import '../../rendering/game_world_3d_painter.dart';
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

  // Swipe gesture tracking (Subway Surfers / Temple Run controls!)
  Offset? _dragStart;

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

      // Safe delta time clamp to prevent physics jumps
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

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragStart == null) return;
    final velocity = details.velocity.pixelsPerSecond;
    final vx = velocity.dx;
    final vy = velocity.dy;

    // Minimum velocity threshold for swipe
    if (vx.abs() > 150 || vy.abs() > 150) {
      if (vx.abs() > vy.abs()) {
        // Horizontal Swipe (Left / Right Lane Switch)
        if (vx < 0) {
          _controller.swipeLeft();
        } else {
          _controller.swipeRight();
        }
      } else {
        // Vertical Swipe (Jump / Slide)
        if (vy < 0) {
          _controller.swipeUp(); // Jump
        } else {
          _controller.swipeDown(); // Slide
        }
      }
    }
    _dragStart = null;
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
    // Screen shake calculation
    double shakeX = 0;
    double shakeY = 0;
    if (_controller.screenShake > 0) {
      shakeX = (Random().nextDouble() * 2 - 1) * 8 * _controller.screenShake;
      shakeY = (Random().nextDouble() * 2 - 1) * 8 * _controller.screenShake;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _handlePanStart,
        onPanEnd: _handlePanEnd,
        onDoubleTap: () {
          // Double-tap anywhere to kiss if in range!
          if (_controller.eligibleKissTarget != null) {
            _controller.performKiss();
          }
        },
        child: Stack(
          children: [
            // 3D Perspective Viewport (Subway Surfers / Temple Run Camera)
            Transform.translate(
              offset: Offset(shakeX, shakeY),
              child: CustomPaint(
                size: Size.infinite,
                painter: GameWorld3DPainter(
                  player: _controller.player,
                  npcs: _controller.npcs,
                  obstacles: _controller.obstacles,
                  coins: _controller.coins,
                  powerUps: _controller.powerUps,
                  level: _controller.currentLevel,
                  particleSystem: _controller.particleSystem,
                  floatingTexts: _controller.floatingTexts,
                  animTime: _controller.animTime,
                ),
              ),
            ),

            // Heads-up Display (HUD) with Controls and Kiss Button
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
      ),
    );
  }
}
