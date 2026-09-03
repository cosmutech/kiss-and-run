import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType { heart, star, anger, sparkle, sweat, siren, coin }

class GameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  double life;
  double maxLife;
  final ParticleType type;
  final Color color;
  final String? emoji;

  GameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.type,
    required this.color,
    this.life = 0.0,
    this.maxLife = 1.0,
    this.alpha = 1.0,
    this.emoji,
  });

  bool get isDead => life >= maxLife;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life += dt;
    alpha = (1.0 - (life / maxLife)).clamp(0.0, 1.0);
  }
}

class ParticleSystem {
  final List<GameParticle> _particles = [];
  final Random _rnd = Random();

  List<GameParticle> get particles => _particles;

  void spawnHearts(double x, double y, {int count = 6}) {
    for (int i = 0; i < count; i++) {
      final angle = _rnd.nextDouble() * pi * 2;
      final speed = 40 + _rnd.nextDouble() * 60;
      _particles.add(GameParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 16.0 + _rnd.nextDouble() * 8,
        type: ParticleType.heart,
        color: Colors.pinkAccent,
        emoji: '❤️',
        maxLife: 0.9 + _rnd.nextDouble() * 0.4,
      ));
    }
  }

  void spawnStars(double x, double y, {int count = 5}) {
    for (int i = 0; i < count; i++) {
      final angle = _rnd.nextDouble() * pi * 2;
      final speed = 50 + _rnd.nextDouble() * 70;
      _particles.add(GameParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 16.0,
        type: ParticleType.star,
        color: Colors.amber,
        emoji: '⭐',
        maxLife: 0.8,
      ));
    }
  }

  void spawnAnger(double x, double y) {
    for (int i = 0; i < 3; i++) {
      _particles.add(GameParticle(
        x: x + (_rnd.nextDouble() * 20 - 10),
        y: y - 20,
        vx: (_rnd.nextDouble() * 40 - 20),
        vy: -40 - _rnd.nextDouble() * 30,
        size: 18.0,
        type: ParticleType.anger,
        color: Colors.redAccent,
        emoji: '💢',
        maxLife: 1.0,
      ));
    }
  }

  void spawnCoinSparkles(double x, double y, {int count = 4}) {
    for (int i = 0; i < count; i++) {
      _particles.add(GameParticle(
        x: x + (_rnd.nextDouble() * 20 - 10),
        y: y,
        vx: (_rnd.nextDouble() * 40 - 20),
        vy: -50 - _rnd.nextDouble() * 40,
        size: 14.0,
        type: ParticleType.coin,
        color: Colors.yellow,
        emoji: '✨',
        maxLife: 0.7,
      ));
    }
  }

  void update(double dt) {
    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
  }

  void clear() {
    _particles.clear();
  }
}
