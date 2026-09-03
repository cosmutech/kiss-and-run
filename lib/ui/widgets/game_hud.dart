import 'package:flutter/material.dart';
import '../../systems/game_controller.dart';

class GameHUD extends StatelessWidget {
  final GameController controller;
  final VoidCallback onPause;

  const GameHUD({
    super.key,
    required this.controller,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final canKiss = controller.eligibleKissTarget != null;

    return SafeArea(
      child: Stack(
        children: [
          // Top Status Bar
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Health Hearts
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: List.generate(
                      controller.player.maxHealth,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          index < controller.player.health ? '❤️' : '🖤',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),

                // Score and Combo Display
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Text('🏆 ', style: TextStyle(fontSize: 16)),
                          Text(
                            '${controller.score}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.combo > 1) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.deepOrangeAccent, blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          '🔥 COMBO x${controller.combo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Coins and Pause
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pinkAccent),
                      ),
                      child: Row(
                        children: [
                          const Text('💰 ', style: TextStyle(fontSize: 15)),
                          Text(
                            '${controller.runHeartCoins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 34),
                      onPressed: onPause,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chaser Proximity Alert Bar (Subway Surfers style inspector behind you!)
          if (controller.player.hasChaser)
            Positioned(
              top: 75,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: Row(
                  children: [
                    Text(
                      controller.player.chaserTypeId == 'police_officer' ? '🚨' : '🤬',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PURSUER: ${controller.player.chaserName.toUpperCase()}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          LinearProgressIndicator(
                            value: (controller.player.chaserDistance / 100.0).clamp(0.0, 1.0),
                            backgroundColor: Colors.black54,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              controller.player.chaserDistance < 35 ? Colors.redAccent : Colors.amber,
                            ),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.player.chaserDistance < 35 ? '⚠️ CLOSE!' : 'ESC: ${(controller.player.chaserDistance).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),

          // Comic Event Banner
          if (controller.activeEventBanner != null)
            Positioned(
              top: controller.player.hasChaser ? 125 : 75,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, offset: Offset(2, 4), blurRadius: 6),
                    ],
                  ),
                  child: Text(
                    controller.activeEventBanner!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Bottom Controls & Big 💋 KISS Button
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Lane Switch Quick Buttons (Left / Right)
                Row(
                  children: [
                    _controlButton(
                      icon: Icons.arrow_back,
                      label: 'LEFT',
                      onTap: () => controller.swipeLeft(),
                    ),
                    const SizedBox(width: 10),
                    _controlButton(
                      icon: Icons.arrow_forward,
                      label: 'RIGHT',
                      onTap: () => controller.swipeRight(),
                    ),
                  ],
                ),

                // Jump and Slide Quick Buttons
                Row(
                  children: [
                    _controlButton(
                      icon: Icons.arrow_upward,
                      label: 'JUMP',
                      color: Colors.deepPurpleAccent,
                      onTap: () => controller.swipeUp(),
                    ),
                    const SizedBox(width: 10),
                    _controlButton(
                      icon: Icons.arrow_downward,
                      label: 'SLIDE',
                      color: Colors.teal,
                      onTap: () => controller.swipeDown(),
                    ),
                  ],
                ),

                // BIG 💋 KISS BUTTON (lights up neon pink when near pedestrian!)
                GestureDetector(
                  onTap: canKiss ? () => controller.performKiss() : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: canKiss ? 84 : 70,
                    height: canKiss ? 84 : 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canKiss
                            ? [const Color(0xFFFF4081), const Color(0xFFE91E63)]
                            : [Colors.grey.shade700, Colors.grey.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: canKiss ? Colors.white : Colors.white24,
                        width: canKiss ? 4 : 2,
                      ),
                      boxShadow: canKiss
                          ? [
                              const BoxShadow(
                                color: Colors.pinkAccent,
                                blurRadius: 20,
                                spreadRadius: 4,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💋', style: TextStyle(fontSize: canKiss ? 32 : 24)),
                          Text(
                            'KISS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: canKiss ? 12 : 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    Color color = Colors.black45,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white38),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
