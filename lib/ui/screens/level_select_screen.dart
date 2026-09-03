import 'package:flutter/material.dart';
import '../../data/level_definitions.dart';
import '../../systems/save_manager.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highestUnlocked = SaveManager.getHighestLevel();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SELECT STAGE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: LevelDefinitions.levels.length,
        itemBuilder: (context, index) {
          final level = LevelDefinitions.levels[index];
          final isUnlocked = level.levelNumber <= highestUnlocked;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUnlocked
                    ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                    : [const Color(0xFF1E1E1E), const Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnlocked ? level.accentColor : Colors.white12,
                width: isUnlocked ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked ? level.accentColor : Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? '${level.levelNumber}' : '🔒',
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              title: Text(
                level.title,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white38,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isUnlocked
                      ? 'Goal: ${level.targetKisses} Kisses • ${level.description}'
                      : 'Reach Stage ${level.levelNumber - 1} to Unlock',
                  style: TextStyle(
                    color: isUnlocked ? Colors.white70 : Colors.white24,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: isUnlocked
                  ? const Icon(Icons.play_circle_fill, color: Colors.pinkAccent, size: 36)
                  : null,
              onTap: isUnlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => GameScreen(level: level),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
