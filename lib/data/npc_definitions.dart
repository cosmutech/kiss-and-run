import 'package:flutter/material.dart';

class NPCTypeConfig {
  final String id;
  final String name;
  final String gender;
  final Color hairColor;
  final Color shirtColor;
  final Color pantsColor;
  final Color skinTone;
  final String accessoryEmoji;
  final double baseSpeed;
  final Map<String, double> reactionWeights;

  const NPCTypeConfig({
    required this.id,
    required this.name,
    required this.gender,
    required this.hairColor,
    required this.shirtColor,
    required this.pantsColor,
    required this.skinTone,
    this.accessoryEmoji = '',
    this.baseSpeed = 95.0,
    required this.reactionWeights,
  });
}

class NPCDefinitions {
  static const List<NPCTypeConfig> allTypes = [
    // 1. Happy Girl
    NPCTypeConfig(
      id: 'happy_girl',
      name: 'Happy Girl',
      gender: 'female',
      hairColor: Color(0xFFFFD54F),
      shirtColor: Color(0xFFFF4081),
      pantsColor: Color(0xFFE040FB),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '🎀',
      baseSpeed: 95.0,
      reactionWeights: {
        'love': 0.50,
        'laugh': 0.20,
        'run_away': 0.15,
        'slap': 0.10,
        'call_friends': 0.05,
      },
    ),

    // 2. Angry Girl
    NPCTypeConfig(
      id: 'angry_girl',
      name: 'Angry Girl',
      gender: 'female',
      hairColor: Color(0xFFD32F2F),
      shirtColor: Color(0xFFFF5252),
      pantsColor: Color(0xFF212121),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '💢',
      baseSpeed: 110.0,
      reactionWeights: {
        'chase': 0.50,
        'slap': 0.30,
        'call_police': 0.10,
        'throw_object': 0.10,
      },
    ),

    // 3. Shy Girl
    NPCTypeConfig(
      id: 'shy_girl',
      name: 'Shy Girl',
      gender: 'female',
      hairColor: Color(0xFF8D6E63),
      shirtColor: Color(0xFFB39DDB),
      pantsColor: Color(0xFF90CAF9),
      skinTone: Color(0xFFFFF0E1),
      accessoryEmoji: '🌸',
      baseSpeed: 85.0,
      reactionWeights: {
        'run_away': 0.40,
        'freeze': 0.30,
        'love': 0.20,
        'laugh': 0.10,
      },
    ),

    // 4. Funny Guy
    NPCTypeConfig(
      id: 'funny_guy',
      name: 'Funny Guy',
      gender: 'male',
      hairColor: Color(0xFF424242),
      shirtColor: Color(0xFFFFEB3B),
      pantsColor: Color(0xFF00E676),
      skinTone: Color(0xFFE0AC69),
      accessoryEmoji: '🤪',
      baseSpeed: 100.0,
      reactionWeights: {
        'laugh': 0.45,
        'take_photo': 0.25,
        'freeze': 0.15,
        'chase': 0.15,
      },
    ),

    // 5. Angry Guy
    NPCTypeConfig(
      id: 'angry_guy',
      name: 'Angry Guy',
      gender: 'male',
      hairColor: Color(0xFF212121),
      shirtColor: Color(0xFFE65100),
      pantsColor: Color(0xFF263238),
      skinTone: Color(0xFFC68642),
      accessoryEmoji: '🥊',
      baseSpeed: 120.0,
      reactionWeights: {
        'chase': 0.60,
        'slap': 0.20,
        'call_police': 0.10,
        'throw_object': 0.10,
      },
    ),

    // 6. Romantic Guy
    NPCTypeConfig(
      id: 'romantic_guy',
      name: 'Romantic Guy',
      gender: 'male',
      hairColor: Color(0xFF5D4037),
      shirtColor: Color(0xFFE91E63),
      pantsColor: Color(0xFFECEFF1),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '🌹',
      baseSpeed: 90.0,
      reactionWeights: {
        'kiss_back': 0.50,
        'love': 0.25,
        'gift': 0.15,
        'join': 0.10,
      },
    ),

    // 7. Serious Businessman
    NPCTypeConfig(
      id: 'businessman',
      name: 'Serious Businessman',
      gender: 'male',
      hairColor: Color(0xFF9E9E9E),
      shirtColor: Color(0xFF1A237E),
      pantsColor: Color(0xFF0D47A1),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '💼',
      baseSpeed: 105.0,
      reactionWeights: {
        'call_police': 0.40,
        'slap': 0.30,
        'scream': 0.20,
        'freeze': 0.10,
      },
    ),

    // 8. Tourist
    NPCTypeConfig(
      id: 'tourist',
      name: 'Tourist',
      gender: 'male',
      hairColor: Color(0xFFFFA000),
      shirtColor: Color(0xFF00BCD4),
      pantsColor: Color(0xFFFFB74D),
      skinTone: Color(0xFFE0AC69),
      accessoryEmoji: '📷',
      baseSpeed: 80.0,
      reactionWeights: {
        'take_photo': 0.45,
        'laugh': 0.30,
        'gift': 0.15,
        'freeze': 0.10,
      },
    ),

    // 9. Fitness Guy
    NPCTypeConfig(
      id: 'fitness_guy',
      name: 'Fitness Guy',
      gender: 'male',
      hairColor: Color(0xFF3E2723),
      shirtColor: Color(0xFF76FF03),
      pantsColor: Color(0xFF212121),
      skinTone: Color(0xFF8D5524),
      accessoryEmoji: '💪',
      baseSpeed: 130.0,
      reactionWeights: {
        'chase': 0.65,
        'throw_object': 0.20,
        'laugh': 0.15,
      },
    ),

    // 10. Grandma
    NPCTypeConfig(
      id: 'grandma',
      name: 'Grandma',
      gender: 'female',
      hairColor: Color(0xFFEEEEEE),
      shirtColor: Color(0xFFBA68C8),
      pantsColor: Color(0xFF7E57C2),
      skinTone: Color(0xFFFFE0BD),
      accessoryEmoji: '👵',
      baseSpeed: 70.0,
      reactionWeights: {
        'throw_object': 0.40,
        'gift': 0.30,
        'scream': 0.20,
        'freeze': 0.10,
      },
    ),

    // 11. Security Guard
    NPCTypeConfig(
      id: 'security_guard',
      name: 'Security Guard',
      gender: 'male',
      hairColor: Color(0xFF212121),
      shirtColor: Color(0xFF37474F),
      pantsColor: Color(0xFF263238),
      skinTone: Color(0xFFC68642),
      accessoryEmoji: '🛡️',
      baseSpeed: 125.0,
      reactionWeights: {
        'chase': 0.70,
        'crowd': 0.20,
        'call_police': 0.10,
      },
    ),

    // 12. Police Officer
    NPCTypeConfig(
      id: 'police_officer',
      name: 'Police Officer',
      gender: 'male',
      hairColor: Color(0xFF212121),
      shirtColor: Color(0xFF1565C0),
      pantsColor: Color(0xFF0D47A1),
      skinTone: Color(0xFFE0AC69),
      accessoryEmoji: '👮',
      baseSpeed: 140.0,
      reactionWeights: {
        'chase': 0.80,
        'crowd': 0.20,
      },
    ),

    // 13. Street Vendor
    NPCTypeConfig(
      id: 'street_vendor',
      name: 'Street Vendor',
      gender: 'male',
      hairColor: Color(0xFF4E342E),
      shirtColor: Color(0xFFFF6F00),
      pantsColor: Color(0xFF5D4037),
      skinTone: Color(0xFFC68642),
      accessoryEmoji: '🌭',
      baseSpeed: 95.0,
      reactionWeights: {
        'throw_object': 0.50,
        'chase': 0.30,
        'scream': 0.20,
      },
    ),

    // 14. Food Worker
    NPCTypeConfig(
      id: 'food_worker',
      name: 'Food Worker',
      gender: 'female',
      hairColor: Color(0xFFF57C00),
      shirtColor: Color(0xFFFFF176),
      pantsColor: Color(0xFFD32F2F),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '🍕',
      baseSpeed: 100.0,
      reactionWeights: {
        'throw_object': 0.40,
        'chase': 0.30,
        'laugh': 0.20,
        'gift': 0.10,
      },
    ),

    // 15. Random Pedestrian
    NPCTypeConfig(
      id: 'pedestrian',
      name: 'Random Pedestrian',
      gender: 'female',
      hairColor: Color(0xFF6D4C41),
      shirtColor: Color(0xFF26A69A),
      pantsColor: Color(0xFF37474F),
      skinTone: Color(0xFFFFDFC4),
      accessoryEmoji: '🚶',
      baseSpeed: 90.0,
      reactionWeights: {
        'laugh': 0.25,
        'slap': 0.25,
        'love': 0.20,
        'run_away': 0.15,
        'chase': 0.15,
      },
    ),
  ];

  static NPCTypeConfig getById(String id) {
    return allTypes.firstWhere(
      (npc) => npc.id == id,
      orElse: () => allTypes.last,
    );
  }
}
