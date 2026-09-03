enum ObstacleType {
  roadblockLow,     // Low barrier: MUST JUMP! (Subway Surfers style)
  overheadBarrier,  // Overhead sign/barrier: MUST SLIDE!
  bananaPeel,       // Slip hazard: causes spin/stumble!
  foodCart,         // Food cart in lane: triggers domino crash!
  dogAlert,         // Dog on sidewalk/lane
}

class ObstacleModel {
  final String id;
  final ObstacleType type;
  final String name;
  final String emoji;
  double lane; // -1, 0, 1
  double z; // distance along track
  bool requiresJump;
  bool requiresSlide;
  bool hasCollided;

  ObstacleModel({
    required this.id,
    required this.type,
    required this.name,
    required this.emoji,
    required this.lane,
    required this.z,
    this.requiresJump = false,
    this.requiresSlide = false,
    this.hasCollided = false,
  });
}

class HeartCoinModel {
  final String id;
  double lane;
  double z;
  double y; // height for jumping coin arcs!
  bool isCollected;

  HeartCoinModel({
    required this.id,
    required this.lane,
    required this.z,
    this.y = 0.0,
    this.isCollected = false,
  });
}
