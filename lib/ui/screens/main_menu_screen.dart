import 'package:flutter/material.dart';
import '../../systems/save_manager.dart';
import '../../systems/daily_reward_manager.dart';
import '../../data/level_definitions.dart';
import 'level_select_screen.dart';
import 'game_screen.dart';
import 'customize_screen.dart';
import 'leaderboard_screen.dart';
import 'daily_reward_dialog.dart';
import 'settings_dialog.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _coins = 0;
  int _highScore = 0;
  bool _canClaimDaily = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _refreshData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await SaveManager.init();
    setState(() {
      _coins = SaveManager.getHeartCoins();
      _highScore = SaveManager.getHighScore();
      _canClaimDaily = DailyRewardManager.canClaimToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Animated Background Accents
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pinkAccent.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurpleAccent.withOpacity(0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar / Balance & Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Heart Coins Balance Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.pinkAccent, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('❤️ ', style: TextStyle(fontSize: 18)),
                            Text(
                              '$_coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // High Score & Settings
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amber, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Text('🏆 ', style: TextStyle(fontSize: 16)),
                                Text(
                                  '$_highScore',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => SettingsDialog(
                                  onSettingsChanged: _refreshData,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // LOGO: KISS & RUN
                Column(
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1.05).animate(
                        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pinkAccent.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.35),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Text('💋', style: TextStyle(fontSize: 68)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF4081), Color(0xFFFF80AB), Color(0xFFFFD54F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'KISS & RUN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'APPROACH • KISS • ESCAPE! 😂',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // MENU BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    children: [
                      // PLAY CAMPAIGN BUTTON
                      _menuButton(
                        label: 'PLAY CAMPAIGN',
                        icon: Icons.play_arrow_rounded,
                        gradient: const [Color(0xFFFF4081), Color(0xFFE91E63)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const LevelSelectScreen(),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                      const SizedBox(height: 14),

                      // ENDLESS RUN BUTTON
                      _menuButton(
                        label: 'ENDLESS MODE ♾️',
                        icon: Icons.all_inclusive,
                        gradient: const [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => GameScreen(level: LevelDefinitions.endless),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                      const SizedBox(height: 14),

                      // CUSTOMIZE & CHARACTERS BUTTON
                      _menuButton(
                        label: 'DRESSING ROOM 👕',
                        icon: Icons.checkroom,
                        gradient: const [Color(0xFF00B0FF), Color(0xFF0091EA)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const CustomizeScreen(),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                      const SizedBox(height: 14),

                      // Row: LEADERBOARD & DAILY REWARD
                      Row(
                        children: [
                          Expanded(
                            child: _secondaryButton(
                              label: 'RECORDS 🏆',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => const LeaderboardScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _secondaryButton(
                                  label: 'DAILY GIFT 🎁',
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => DailyRewardDialog(
                                        onClaimed: _refreshData,
                                      ),
                                    );
                                  },
                                ),
                                if (_canClaimDaily)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.red, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Footer version & Google Play readiness note
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'v1.0.0 • Google Play Edition • By Cosmutech',
                    style: TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
