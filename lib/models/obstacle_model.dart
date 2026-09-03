enum ObstacleType { bananaPeel, coffeeSpill, luggage, barricade, foodCart, dog, thrownObject }

class ObstacleModel {
  final String id;
  final ObstacleType type;
  final String name;
  final String emoji;
  double x;
  double y;
  double vx;
  double vy;
  double width;
  double height;
  bool isTriggered;
  bool hasCollided;

  ObstacleModel({
    required this.id,
    required this.type,
    required this.name,
    required this.emoji,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
    this.width = 36.0,
    this.height = 36.0,
    this.isTriggered = false,
    this.hasCollided = false,
  });
}
