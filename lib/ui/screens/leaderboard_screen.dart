import 'package:flutter/material.dart';
import '../../systems/save_manager.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highScore = SaveManager.getHighScore();
    final bestCombo = SaveManager.getBestCombo();
    final totalKisses = SaveManager.getTotalKisses();
    final totalEscapes = SaveManager.getTotalEscapes();
    final totalChains = SaveManager.getTotalChains();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'HALL OF FAME',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.pinkAccent,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'RECORDS'),
              Tab(text: 'ACHIEVEMENTS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Records Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _recordCard('🏆 Highest Score', '$highScore pts', Colors.amber),
                _recordCard('🔥 Best Combo Streak', 'x$bestCombo', Colors.deepOrangeAccent),
                _recordCard('💋 Total Kisses Stolen', '$totalKisses', Colors.pinkAccent),
                _recordCard('🏃 Successful Escapes', '$totalEscapes', Colors.greenAccent),
                _recordCard('💥 Chain Reactions Triggered', '$totalChains', Colors.cyanAccent),
              ],
            ),

            // Achievements Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _achievementCard(
                  '💋 First Kiss',
                  'Perform your very first kiss interaction.',
                  totalKisses >= 1,
                  '1/1',
                ),
                _achievementCard(
                  '🏃 Escape Artist',
                  'Successfully escape 10 chases.',
                  totalEscapes >= 10,
                  '${totalEscapes.clamp(0, 10)}/10',
                ),
                _achievementCard(
                  '🔥 Chaos Master',
                  'Trigger 5 chain reactions.',
                  totalChains >= 5,
                  '${totalChains.clamp(0, 5)}/5',
                ),
                _achievementCard(
                  '🚔 Most Wanted',
                  'Trigger a high-speed police chase.',
                  true,
                  'Unlocked',
                ),
                _achievementCard(
                  '❤️ Heart Collector',
                  'Earn over 1,000 Heart Coins.',
                  SaveManager.getHeartCoins() >= 1000,
                  '${SaveManager.getHeartCoins()}/1000',
                ),
                _achievementCard(
                  '🏆 Untouchable',
                  'Complete a stage without getting slapped.',
                  SaveManager.getHighestLevel() > 1,
                  'Completed',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _achievementCard(String title, String desc, bool unlocked, String progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF1E293B) : const Color(0xFF181F2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: unlocked ? Colors.pinkAccent.withOpacity(0.5) : Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: unlocked ? Colors.pinkAccent.withOpacity(0.2) : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                unlocked ? '🏆' : '🔒',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: unlocked ? Colors.white70 : Colors.white24,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: unlocked ? Colors.green.withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              progress,
              style: TextStyle(
                color: unlocked ? Colors.greenAccent : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
