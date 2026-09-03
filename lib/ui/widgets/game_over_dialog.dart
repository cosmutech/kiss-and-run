import 'package:flutter/material.dart';
import '../../systems/game_controller.dart';
import '../../systems/ads_manager.dart';
import '../../systems/save_manager.dart';

class GameOverDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.controller,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final highScore = SaveManager.getHighScore();
    final isNewRecord = controller.score >= highScore && controller.score > 0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.redAccent, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Defeat Avatar / Icon
              const Text('😵‍💫', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 6),
              const Text(
                'YOU GOT CAUGHT! 😂',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Stats Board
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _statRow('Score', '${controller.score}', Colors.amber, isHighlight: isNewRecord),
                    _statRow('Best Score', '$highScore', Colors.white70),
                    const Divider(color: Colors.white24, height: 16),
                    _statRow('Kisses Stolen', '${controller.kissCount}', Colors.pinkAccent),
                    _statRow('Coins Earned', '+${controller.runHeartCoins}', Colors.yellowAccent),
                    _statRow('Best Combo', 'x${controller.combo}', Colors.deepOrangeAccent),
                    _statRow('Chain Reactions', '${controller.chainReactionCount}', Colors.cyanAccent),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // WATCH AD TO REVIVE BUTTON
              ElevatedButton.icon(
                icon: const Text('🎁', style: TextStyle(fontSize: 20)),
                label: const Text(
                  'WATCH AD TO REVIVE (+3 ❤️)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  AdsManager.showRewardedAd(
                    onRewardEarned: () {
                      controller.revivePlayer();
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              // TRY AGAIN BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'TRY AGAIN',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4081),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  controller.restartLevel();
                },
              ),
              const SizedBox(height: 8),

              // HOME BUTTON
              TextButton.icon(
                icon: const Icon(Icons.home, color: Colors.white70),
                label: const Text(
                  'RETURN TO MENU',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                onPressed: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Row(
            children: [
              if (isHighlight) ...[
                const Text('NEW! ', style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
              Text(
                value,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
