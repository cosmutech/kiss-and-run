enum PowerUpType { heartShield, speedBoost, heartMagnet, slowMotion, angelMode, chaosMode }

class PowerUpModel {
  final String id;
  final PowerUpType type;
  final String name;
  final String iconEmoji;
  final String description;
  final double duration; // in seconds
  double x;
  double y;
  bool isCollected;

  PowerUpModel({
    required this.id,
    required this.type,
    required this.name,
    required this.iconEmoji,
    required this.description,
    this.duration = 6.0,
    required this.x,
    required this.y,
    this.isCollected = false,
  });
}
