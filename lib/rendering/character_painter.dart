import 'dart:math';
import 'package:flutter/material.dart';

class CharacterPainter {
  /// Draw a complete cartoon character (player or NPC)
  static void drawCharacter({
    required Canvas canvas,
    required double x,
    required double y,
    required double facingDirection,
    required Color skinTone,
    required Color hairColor,
    required int hairStyle,
    required Color shirtColor,
    required Color pantsColor,
    required int accessoryIndex,
    required bool isKissing,
    required bool isSlapped,
    required bool isLove,
    required bool isAngry,
    required bool isMoving,
    required double animTime,
    double scale = 1.0,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale * facingDirection, scale);

    // 1. Drop shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 36), width: 34, height: 12),
      shadowPaint,
    );

    // 2. Animated Legs
    final legCycle = isMoving ? sin(animTime * 14) : 0.0;
    final legPaint = Paint()
      ..color = pantsColor
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    // Left leg
    canvas.drawLine(
      const Offset(-6, 18),
      Offset(-6 - (legCycle * 8), 34),
      legPaint,
    );
    // Right leg
    canvas.drawLine(
      const Offset(6, 18),
      Offset(6 + (legCycle * 8), 34),
      legPaint,
    );

    // Shoes
    final shoePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(Offset(-6 - (legCycle * 8), 35), 4.5, shoePaint);
    canvas.drawCircle(Offset(6 + (legCycle * 8), 35), 4.5, shoePaint);

    // 3. Torso / Shirt
    final shirtPaint = Paint()..color = shirtColor;
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 6), width: 26, height: 26),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRRect, shirtPaint);

    // Arms
    final armPaint = Paint()
      ..color = shirtColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    if (isKissing) {
      // Reaching forward
      canvas.drawLine(const Offset(4, 2), const Offset(16, 6), armPaint);
    } else if (isAngry) {
      // Shaking fist
      canvas.drawLine(const Offset(8, 2), const Offset(14, -6), armPaint);
    } else {
      // Natural sway
      final armCycle = isMoving ? sin(animTime * 14) : 0.0;
      canvas.drawLine(
        const Offset(-10, 2),
        Offset(-12, 14 + (armCycle * 6)),
        armPaint,
      );
      canvas.drawLine(
        const Offset(10, 2),
        Offset(12, 14 - (armCycle * 6)),
        armPaint,
      );
    }

    // 4. Head
    final headPaint = Paint()..color = skinTone;
    const headCenter = Offset(0, -14);
    canvas.drawCircle(headCenter, 16.0, headPaint);

    // Blushing cheeks
    if (isKissing || isLove) {
      final blushPaint = Paint()..color = Colors.redAccent.withOpacity(0.5);
      canvas.drawCircle(const Offset(-7, -9), 4.0, blushPaint);
      canvas.drawCircle(const Offset(7, -9), 4.0, blushPaint);
    }

    // 5. Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    if (isSlapped) {
      // Stunned X eyes
      final xPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0;
      canvas.drawLine(const Offset(-8, -17), const Offset(-2, -11), xPaint);
      canvas.drawLine(const Offset(-8, -11), const Offset(-2, -17), xPaint);
      canvas.drawLine(const Offset(2, -17), const Offset(8, -11), xPaint);
      canvas.drawLine(const Offset(2, -11), const Offset(8, -17), xPaint);
    } else if (isLove) {
      // Heart eyes
      final heartPaint = Paint()..color = Colors.pinkAccent;
      canvas.drawCircle(const Offset(-5, -14), 3.5, heartPaint);
      canvas.drawCircle(const Offset(5, -14), 3.5, heartPaint);
    } else {
      // Regular cartoon eyes
      canvas.drawCircle(const Offset(-5, -14), 3.8, eyeWhite);
      canvas.drawCircle(const Offset(5, -14), 3.8, eyeWhite);
      final lookOffset = isKissing ? 2.0 : 0.0;
      canvas.drawCircle(Offset(-5 + lookOffset, -14), 2.0, pupilPaint);
      canvas.drawCircle(Offset(5 + lookOffset, -14), 2.0, pupilPaint);
    }

    // 6. Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isKissing) {
      // Kiss pucker
      final puckerPaint = Paint()..color = Colors.redAccent;
      canvas.drawCircle(const Offset(7, -6), 4.0, puckerPaint);
    } else if (isAngry) {
      // Angry frown
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -3), width: 10, height: 8),
        pi,
        pi,
        false,
        mouthPaint,
      );
    } else {
      // Happy smile
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -8), width: 10, height: 8),
        0,
        pi,
        false,
        mouthPaint,
      );
    }

    // 7. Hair
    final hPaint = Paint()..color = hairColor;
    if (hairStyle == 0) {
      // Classic sweep
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -20), width: 32, height: 18),
        pi,
        pi,
        true,
        hPaint,
      );
    } else if (hairStyle == 1) {
      // Spiky punk
      final path = Path();
      path.moveTo(-16, -20);
      path.lineTo(-10, -32);
      path.lineTo(-4, -20);
      path.lineTo(2, -34);
      path.lineTo(8, -20);
      path.lineTo(14, -30);
      path.lineTo(16, -18);
      path.close();
      canvas.drawPath(path, hPaint);
    } else if (hairStyle == 2) {
      // Curly
      canvas.drawCircle(const Offset(-10, -22), 8, hPaint);
      canvas.drawCircle(const Offset(0, -26), 9, hPaint);
      canvas.drawCircle(const Offset(10, -22), 8, hPaint);
    } else if (hairStyle == 3) {
      // Ponytail
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -20), width: 32, height: 18),
        pi,
        pi,
        true,
        hPaint,
      );
      canvas.drawCircle(const Offset(-16, -20), 8, hPaint);
    }

    // 8. Accessories
    if (accessoryIndex == 1) {
      // Cool Sunglasses
      final shadesPaint = Paint()..color = const Color(0xFF111111);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -14), width: 26, height: 8),
          const Radius.circular(2),
        ),
        shadesPaint,
      );
    } else if (accessoryIndex == 2) {
      // Streetwear Cap
      final capPaint = Paint()..color = Colors.deepOrange;
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -22), width: 32, height: 16),
        pi,
        pi,
        true,
        capPaint,
      );
      canvas.drawRect(const Offset(-18, -22) & const Size(12, 4), capPaint);
    } else if (accessoryIndex == 3) {
      // Headphones
      final hpPaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -16), width: 36, height: 32),
        pi,
        pi,
        false,
        hpPaint,
      );
      final earPaint = Paint()..color = Colors.cyanAccent;
      canvas.drawCircle(const Offset(-17, -14), 5, earPaint);
      canvas.drawCircle(const Offset(17, -14), 5, earPaint);
    } else if (accessoryIndex == 4) {
      // Hero Bandana
      final bandanaPaint = Paint()..color = Colors.red;
      canvas.drawRect(const Offset(-16, -23) & const Size(32, 6), bandanaPaint);
    } else if (accessoryIndex == 5) {
      // Angel Halo
      final haloPaint = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -36), width: 28, height: 10),
        haloPaint,
      );
    }

    canvas.restore();
  }

  /// Draw a comic speech bubble above the NPC
  static void drawSpeechBubble({
    required Canvas canvas,
    required double x,
    required double y,
    required String text,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 160);

    final bubbleWidth = tp.width + 16;
    final bubbleHeight = tp.height + 12;
    final bubbleRect = Rect.fromCenter(
      center: Offset(x, y - 55),
      width: bubbleWidth,
      height: bubbleHeight,
    );

    // Bubble background
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(bubbleRect, const Radius.circular(10));
    canvas.drawRRect(rrect, bubblePaint);
    canvas.drawRRect(rrect, borderPaint);

    // Pointer tail
    final tailPath = Path();
    tailPath.moveTo(x - 5, y - 55 + bubbleHeight / 2);
    tailPath.lineTo(x, y - 44);
    tailPath.lineTo(x + 5, y - 55 + bubbleHeight / 2);
    tailPath.close();
    canvas.drawPath(tailPath, bubblePaint);
    canvas.drawPath(tailPath, borderPaint);

    tp.paint(
      canvas,
      Offset(bubbleRect.left + 8, bubbleRect.top + 6),
    );
  }
}
