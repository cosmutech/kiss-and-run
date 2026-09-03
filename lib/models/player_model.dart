enum PlayerState { idle, running, jumping, sliding, kissing, slapped }

class PlayerModel {
  // 3D Lane System: -1 = Left, 0 = Center, 1 = Right
  int targetLane;
  double currentLanePos; // Smoothly interpolates to targetLane
  double z; // Forward position along the track
  double speed;
  double baseSpeed;

  // Vertical movement (Jump & Slide)
  double jumpY; // 0 = on ground, >0 = in air
  double jumpVy;
  double slideTimer; // >0 means sliding
  final double slideDuration = 0.7;

  int health;
  final int maxHealth;

  String gender; // 'male' or 'female'
  int skinToneIndex;
  int hairStyleIndex;
  int hairColorIndex;
  int shirtColorIndex;
  int pantsColorIndex;
  int accessoryIndex;

  PlayerState state;
  double stateTimer;

  // The Chaser breathing down your neck (Subway Surfers / Temple Run mechanic!)
  bool hasChaser;
  double chaserDistance; // 100 = safe distance, 0 = tackles player!
  String chaserTypeId;
  String chaserName;

  // Buffs and timers
  bool hasShield;
  double speedBoostTimer;
  double magnetTimer;
  double slowMoTimer;
  double angelTimer;
  double chaosTimer;
  double invincibilityTimer;
  double stunTimer;

  PlayerModel({
    this.targetLane = 0,
    this.currentLanePos = 0.0,
    this.z = 0.0,
    this.baseSpeed = 380.0,
    this.speed = 380.0,
    this.jumpY = 0.0,
    this.jumpVy = 0.0,
    this.slideTimer = 0.0,
    this.health = 3,
    this.maxHealth = 3,
    this.gender = 'male',
    this.skinToneIndex = 1,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.shirtColorIndex = 0,
    this.pantsColorIndex = 0,
    this.accessoryIndex = 0,
    this.state = PlayerState.running,
    this.stateTimer = 0.0,
    this.hasChaser = false,
    this.chaserDistance = 100.0,
    this.chaserTypeId = 'angry_guy',
    this.chaserName = 'Angry Guy',
    this.hasShield = false,
    this.speedBoostTimer = 0.0,
    this.magnetTimer = 0.0,
    this.slowMoTimer = 0.0,
    this.angelTimer = 0.0,
    this.chaosTimer = 0.0,
    this.invincibilityTimer = 0.0,
    this.stunTimer = 0.0,
  });

  bool get isJumping => jumpY > 0.01;
  bool get isSliding => slideTimer > 0;
  bool get isInvincible => invincibilityTimer > 0;
  bool get hasSpeedBoost => speedBoostTimer > 0;
  bool get hasMagnet => magnetTimer > 0;
  bool get hasSlowMo => slowMoTimer > 0;
  bool get isAngel => angelTimer > 0;
  bool get isChaos => chaosTimer > 0;
  bool get isStunned => stunTimer > 0;

  void switchLane(int direction) {
    targetLane = (targetLane + direction).clamp(-1, 1);
  }

  void jump() {
    if (!isJumping && !isSliding && !isStunned) {
      jumpVy = 520.0;
      state = PlayerState.jumping;
    }
  }

  void slide() {
    if (isJumping) {
      // Fast drop down (like Subway Surfers!)
      jumpVy = -600.0;
    }
    if (!isSliding && !isStunned) {
      slideTimer = slideDuration;
      state = PlayerState.sliding;
    }
  }

  void takeDamage(int amount) {
    if (isInvincible) return;
    if (hasShield) {
      hasShield = false;
      invincibilityTimer = 1.5;
      return;
    }
    health = (health - amount).clamp(0, maxHealth);
    invincibilityTimer = 1.8;
    stunTimer = 0.4;
    state = PlayerState.slapped;
    // Stumble causes chaser to close in!
    chaserDistance = (chaserDistance - 40).clamp(0.0, 100.0);
  }

  void reset() {
    targetLane = 0;
    currentLanePos = 0.0;
    z = 0.0;
    jumpY = 0.0;
    jumpVy = 0.0;
    slideTimer = 0.0;
    health = maxHealth;
    state = PlayerState.running;
    stateTimer = 0;
    hasChaser = false;
    chaserDistance = 100.0;
    hasShield = false;
    speedBoostTimer = 0;
    magnetTimer = 0;
    slowMoTimer = 0;
    angelTimer = 0;
    chaosTimer = 0;
    invincibilityTimer = 0;
    stunTimer = 0;
  }
}
