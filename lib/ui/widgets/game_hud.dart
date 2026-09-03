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
                          style: const TextStyle(fontSize: 20),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Heart Coins and Pause Button
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
                          const Text('💰 ', style: TextStyle(fontSize: 16)),
                          Text(
                            '${controller.runHeartCoins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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

          // Comic Event Banner
          if (controller.activeEventBanner != null)
            Positioned(
              top: 75,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Level Objective Indicator
          if (!controller.currentLevel.isEndless)
            Positioned(
              top: 120,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💋 Kisses: ${controller.kissCount}/${controller.currentLevel.targetKisses}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Controls & KISS Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // D-Pad Directional Arrows
                _buildDPad(),

                // Action Buttons (Jump, Dash, and big KISS)
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDPad() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Up
          Positioned(
            top: 6,
            child: _dPadButton(
              icon: Icons.keyboard_arrow_up,
              onDown: () => controller.inputY = -1.0,
              onUp: () => controller.inputY = 0.0,
            ),
          ),
          // Down
          Positioned(
            bottom: 6,
            child: _dPadButton(
              icon: Icons.keyboard_arrow_down,
              onDown: () => controller.inputY = 1.0,
              onUp: () => controller.inputY = 0.0,
            ),
          ),
          // Left
          Positioned(
            left: 6,
            child: _dPadButton(
              icon: Icons.keyboard_arrow_left,
              onDown: () => controller.inputX = -1.0,
              onUp: () => controller.inputX = 0.0,
            ),
          ),
          // Right
          Positioned(
            right: 6,
            child: _dPadButton(
              icon: Icons.keyboard_arrow_right,
              onDown: () => controller.inputX = 1.0,
              onUp: () => controller.inputX = 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dPadButton({
    required IconData icon,
    required VoidCallback onDown,
    required VoidCallback onUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: () => onUp(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canKiss = controller.eligibleKissTarget != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Secondary actions: Jump and Dash
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.playerJump(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('🦘', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: () => controller.playerDash(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('💨', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // BIG 💋 KISS BUTTON (Pulsates when target is near!)
        GestureDetector(
          onTap: canKiss ? () => controller.performKiss() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: canKiss ? 88 : 74,
            height: canKiss ? 88 : 74,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canKiss
                    ? [const Color(0xFFFF4081), const Color(0xFFE91E63)]
                    : [Colors.grey.shade600, Colors.grey.shade800],
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
                        blurRadius: 18,
                        spreadRadius: 4,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '💋',
                    style: TextStyle(fontSize: canKiss ? 36 : 28),
                  ),
                  Text(
                    'KISS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: canKiss ? 13 : 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
