import 'package:flutter/material.dart';

class LevelModel {
  final int levelNumber;
  final String title;
  final String description;
  final int targetKisses;
  final double worldLength; // pixels
  final List<String> npcPool;
  final double obstacleFrequency;
  final double basePoliceChance;
  final double chainReactionChance;
  final Color groundColor;
  final Color roadColor;
  final Color accentColor;
  final String environmentTheme; // 'street', 'park', 'cafe', 'office', 'beach', 'wedding', 'airport', 'stadium', 'city'

  const LevelModel({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.targetKisses,
    this.worldLength = 3500.0,
    required this.npcPool,
    this.obstacleFrequency = 0.2,
    this.basePoliceChance = 0.05,
    this.chainReactionChance = 0.25,
    this.groundColor = const Color(0xFFE8EEF5),
    this.roadColor = const Color(0xFF4A5568),
    this.accentColor = const Color(0xFFFF4081),
    required this.environmentTheme,
  });

  bool get isEndless => levelNumber > 10;
}
