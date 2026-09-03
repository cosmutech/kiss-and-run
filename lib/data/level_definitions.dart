import 'package:flutter/material.dart';
import '../models/level_model.dart';

class LevelDefinitions {
  static const List<LevelModel> levels = [
    // Level 1: Quiet Street
    LevelModel(
      levelNumber: 1,
      title: 'Level 1 — Quiet Street',
      description: 'A peaceful neighborhood sidewalk. Perfect place to practice!',
      targetKisses: 3,
      worldLength: 3000,
      npcPool: ['happy_girl', 'shy_girl', 'funny_guy', 'pedestrian'],
      obstacleFrequency: 0.1,
      basePoliceChance: 0.0,
      chainReactionChance: 0.15,
      groundColor: Color(0xFFECEFF1),
      roadColor: Color(0xFF607D8B),
      accentColor: Color(0xFFFF4081),
      environmentTheme: 'street',
    ),

    // Level 2: Shopping Street
    LevelModel(
      levelNumber: 2,
      title: 'Level 2 — Shopping Street',
      description: 'Bustling shops and curious tourists. Watch out for vendors!',
      targetKisses: 4,
      worldLength: 3500,
      npcPool: ['happy_girl', 'tourist', 'street_vendor', 'pedestrian', 'funny_guy'],
      obstacleFrequency: 0.2,
      basePoliceChance: 0.05,
      chainReactionChance: 0.25,
      groundColor: Color(0xFFFFF3E0),
      roadColor: Color(0xFF5D4037),
      accentColor: Color(0xFFFF9800),
      environmentTheme: 'shopping',
    ),

    // Level 3: Park
    LevelModel(
      levelNumber: 3,
      title: 'Level 3 — Sunny Park',
      description: 'Green grass, joggers, and energetic dogs off the leash!',
      targetKisses: 5,
      worldLength: 4000,
      npcPool: ['fitness_guy', 'grandma', 'romantic_guy', 'shy_girl', 'pedestrian'],
      obstacleFrequency: 0.25,
      basePoliceChance: 0.05,
      chainReactionChance: 0.35,
      groundColor: Color(0xFFE8F5E9),
      roadColor: Color(0xFF388E3C),
      accentColor: Color(0xFF4CAF50),
      environmentTheme: 'park',
    ),

    // Level 4: Restaurant Area
    LevelModel(
      levelNumber: 4,
      title: 'Level 4 — Restaurant Plaza',
      description: 'Outdoor dining tables, food carts, and slippery spills everywhere!',
      targetKisses: 5,
      worldLength: 4200,
      npcPool: ['food_worker', 'street_vendor', 'angry_girl', 'funny_guy', 'pedestrian'],
      obstacleFrequency: 0.35,
      basePoliceChance: 0.1,
      chainReactionChance: 0.45,
      groundColor: Color(0xFFFFEBEE),
      roadColor: Color(0xFFC2185B),
      accentColor: Color(0xFFE91E63),
      environmentTheme: 'restaurant',
    ),

    // Level 5: Office District
    LevelModel(
      levelNumber: 5,
      title: 'Level 5 — Financial District',
      description: 'Serious business executives and vigilant building security guards!',
      targetKisses: 6,
      worldLength: 4600,
      npcPool: ['businessman', 'security_guard', 'angry_guy', 'shy_girl', 'pedestrian'],
      obstacleFrequency: 0.3,
      basePoliceChance: 0.2,
      chainReactionChance: 0.5,
      groundColor: Color(0xFFE1F5FE),
      roadColor: Color(0xFF0277BD),
      accentColor: Color(0xFF00BCD4),
      environmentTheme: 'office',
    ),

    // Level 6: Beach
    LevelModel(
      levelNumber: 6,
      title: 'Level 6 — Sunny Beach Boardwalk',
      description: 'Sunbathers, volleyballers, and beach umbrellas to dodge!',
      targetKisses: 6,
      worldLength: 4800,
      npcPool: ['tourist', 'fitness_guy', 'happy_girl', 'romantic_guy', 'pedestrian'],
      obstacleFrequency: 0.35,
      basePoliceChance: 0.15,
      chainReactionChance: 0.5,
      groundColor: Color(0xFFFFF8E1),
      roadColor: Color(0xFFFFB300),
      accentColor: Color(0xFFFFC107),
      environmentTheme: 'beach',
    ),

    // Level 7: Wedding
    LevelModel(
      levelNumber: 7,
      title: 'Level 7 — The Big Wedding',
      description: 'A packed celebration! One wrong kiss triggers massive wedding chaos!',
      targetKisses: 7,
      worldLength: 5000,
      npcPool: ['romantic_guy', 'happy_girl', 'angry_girl', 'grandma', 'funny_guy'],
      obstacleFrequency: 0.4,
      basePoliceChance: 0.2,
      chainReactionChance: 0.75,
      groundColor: Color(0xFFF3E5F5),
      roadColor: Color(0xFF8E24AA),
      accentColor: Color(0xFFAB47BC),
      environmentTheme: 'wedding',
    ),

    // Level 8: Airport
    LevelModel(
      levelNumber: 8,
      title: 'Level 8 — International Terminal',
      description: 'Rolling luggage hazards, TSA security officers, and tight gates!',
      targetKisses: 7,
      worldLength: 5200,
      npcPool: ['tourist', 'businessman', 'security_guard', 'food_worker', 'pedestrian'],
      obstacleFrequency: 0.45,
      basePoliceChance: 0.3,
      chainReactionChance: 0.65,
      groundColor: Color(0xFFECEFF1),
      roadColor: Color(0xFF455A64),
      accentColor: Color(0xFF607D8B),
      environmentTheme: 'airport',
    ),

    // Level 9: Stadium
    LevelModel(
      levelNumber: 9,
      title: 'Level 9 — Mega Arena Concourse',
      description: 'Thousands of hyped fans! Enormous crowds that love to gang up!',
      targetKisses: 8,
      worldLength: 5500,
      npcPool: ['fitness_guy', 'angry_guy', 'street_vendor', 'security_guard', 'funny_guy'],
      obstacleFrequency: 0.5,
      basePoliceChance: 0.35,
      chainReactionChance: 0.8,
      groundColor: Color(0xFFE8EAF6),
      roadColor: Color(0xFF283593),
      accentColor: Color(0xFF3F51B5),
      environmentTheme: 'stadium',
    ),

    // Level 10: City Center
    LevelModel(
      levelNumber: 10,
      title: 'Level 10 — Downtown Core',
      description: 'Maximum security! Police patrols, fast pursuers, full chaos!',
      targetKisses: 10,
      worldLength: 6000,
      npcPool: [
        'police_officer',
        'security_guard',
        'angry_guy',
        'angry_girl',
        'businessman',
        'street_vendor',
        'happy_girl'
      ],
      obstacleFrequency: 0.55,
      basePoliceChance: 0.5,
      chainReactionChance: 0.85,
      groundColor: Color(0xFFFFEBEE),
      roadColor: Color(0xFFB71C1C),
      accentColor: Color(0xFFF44336),
      environmentTheme: 'city',
    ),
  ];

  // Endless Mode definition
  static const LevelModel endless = LevelModel(
    levelNumber: 999,
    title: 'Endless Run',
    description: 'Survive as long as you can! Collect coins, build massive combos!',
    targetKisses: 999999,
    worldLength: 9999999.0,
    npcPool: [
      'happy_girl',
      'angry_girl',
      'shy_girl',
      'funny_guy',
      'angry_guy',
      'romantic_guy',
      'businessman',
      'tourist',
      'fitness_guy',
      'grandma',
      'security_guard',
      'police_officer',
      'street_vendor',
      'food_worker',
      'pedestrian'
    ],
    obstacleFrequency: 0.4,
    basePoliceChance: 0.25,
    chainReactionChance: 0.6,
    groundColor: Color(0xFF212121),
    roadColor: Color(0xFF424242),
    accentColor: Color(0xFFFF4081),
    environmentTheme: 'endless',
  );

  static LevelModel getByNumber(int levelNumber) {
    if (levelNumber > 10) return endless;
    return levels.firstWhere(
      (lvl) => lvl.levelNumber == levelNumber,
      orElse: () => levels.first,
    );
  }
}
