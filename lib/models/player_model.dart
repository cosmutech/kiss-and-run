
enum PlayerState { idle, walking, running, kissing, slapped, sliding, jumping }

class PlayerModel {
  double x;
  double y;
  double vx;
  double vy;
  double baseSpeed;
  double currentSpeed;
  int health;
  final int maxHealth;

  String gender; // 'male' or 'female'
  int skinToneIndex;
  int hairStyleIndex;
  int hairColorIndex;
  int shirtColorIndex;
  int pantsColorIndex;
  int accessoryIndex; // 0: None, 1: Cool Shades, 2: Cap, 3: Headphones, 4: Red Bandana

  PlayerState state;
  double stateTimer;
  double facingDirection; // 1.0 = right, -1.0 = left

  // Buffs and timers
  bool hasShield;
  double speedBoostTimer;
  double magnetTimer;
  double slowMoTimer;
  double angelTimer;
  double chaosTimer;
  double invincibilityTimer;
  double stunTimer;
  double jumpProgress; // 0.0 to 1.0

  PlayerModel({
    this.x = 200,
    this.y = 500,
    this.vx = 0,
    this.vy = 0,
    this.baseSpeed = 220.0,
    this.currentSpeed = 220.0,
    this.health = 3,
    this.maxHealth = 3,
    this.gender = 'male',
    this.skinToneIndex = 1,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.shirtColorIndex = 0,
    this.pantsColorIndex = 0,
    this.accessoryIndex = 0,
    this.state = PlayerState.idle,
    this.stateTimer = 0.0,
    this.facingDirection = 1.0,
    this.hasShield = false,
    this.speedBoostTimer = 0.0,
    this.magnetTimer = 0.0,
    this.slowMoTimer = 0.0,
    this.angelTimer = 0.0,
    this.chaosTimer = 0.0,
    this.invincibilityTimer = 0.0,
    this.stunTimer = 0.0,
    this.jumpProgress = 0.0,
  });

  bool get isInvincible => invincibilityTimer > 0;
  bool get hasSpeedBoost => speedBoostTimer > 0;
  bool get hasMagnet => magnetTimer > 0;
  bool get hasSlowMo => slowMoTimer > 0;
  bool get isAngel => angelTimer > 0;
  bool get isChaos => chaosTimer > 0;
  bool get isStunned => stunTimer > 0;
  bool get isJumping => jumpProgress > 0;

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
  }

  void heal(int amount) {
    health = (health + amount).clamp(0, maxHealth);
  }

  void reset({double startX = 200, double startY = 500}) {
    x = startX;
    y = startY;
    vx = 0;
    vy = 0;
    health = maxHealth;
    state = PlayerState.idle;
    stateTimer = 0;
    hasShield = false;
    speedBoostTimer = 0;
    magnetTimer = 0;
    slowMoTimer = 0;
    angelTimer = 0;
    chaosTimer = 0;
    invincibilityTimer = 0;
    stunTimer = 0;
    jumpProgress = 0;
  }
}
