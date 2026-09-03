import 'package:flutter/material.dart';
import '../../systems/game_controller.dart';

class VictoryDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.controller,
    required this.onNextLevel,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.greenAccent, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐⭐⭐', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              const Text(
                'LEVEL COMPLETE! 🎉',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _statRow('Score', '${controller.score}', Colors.amber),
                    _statRow('Kisses Reached', '${controller.kissCount}', Colors.pinkAccent),
                    _statRow('Heart Coins Earned', '+${controller.runHeartCoins}', Colors.yellowAccent),
                    _statRow('Best Combo', 'x${controller.combo}', Colors.deepOrangeAccent),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // NEXT LEVEL BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'NEXT LEVEL',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onNextLevel,
              ),
              const SizedBox(height: 10),

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

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
