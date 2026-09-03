enum PowerUpType { heartShield, speedBoost, heartMagnet, slowMotion, angelMode, chaosMode }

class PowerUpModel {
  final String id;
  final PowerUpType type;
  final String name;
  final String iconEmoji;
  final String description;
  final double duration;
  double lane;
  double z;
  double y;
  bool isCollected;

  PowerUpModel({
    required this.id,
    required this.type,
    required this.name,
    required this.iconEmoji,
    required this.description,
    this.duration = 7.0,
    required this.lane,
    required this.z,
    this.y = 0.0,
    this.isCollected = false,
  });
}
