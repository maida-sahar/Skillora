import 'dart:math' as math;
import 'package:flutter/material.dart';

enum IsometricIllustrationType { careerGrowth, skillTree, certificateLaptop }

class IsometricCareerIllustration extends StatelessWidget {
  final IsometricIllustrationType type;

  const IsometricCareerIllustration({
    super.key,
    this.type = IsometricIllustrationType.careerGrowth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _IsometricPainter(type: type),
        );
      },
    );
  }
}

class _IsometricPainter extends CustomPainter {
  final IsometricIllustrationType type;

  _IsometricPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (type) {
      case IsometricIllustrationType.careerGrowth:
        _drawCareerGrowth(canvas, size, cx, cy);
        break;
      case IsometricIllustrationType.skillTree:
        _drawSkillTree(canvas, size, cx, cy);
        break;
      case IsometricIllustrationType.certificateLaptop:
        _drawCertificateLaptop(canvas, size, cx, cy);
        break;
    }
  }

  // Draw 3D Isometric Cube / Bar
  void _drawIsometricBar(
    Canvas canvas, {
    required double x,
    required double y,
    required double width,
    required double height,
    required double depth,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
  }) {
    final topPath = Path()
      ..moveTo(x, y - depth)
      ..lineTo(x + width / 2, y - depth - width * 0.25)
      ..lineTo(x + width, y - depth)
      ..lineTo(x + width / 2, y - depth + width * 0.25)
      ..close();

    final leftPath = Path()
      ..moveTo(x, y - depth)
      ..lineTo(x + width / 2, y - depth + width * 0.25)
      ..lineTo(x + width / 2, y - depth + width * 0.25 + height)
      ..lineTo(x, y - depth + height)
      ..close();

    final rightPath = Path()
      ..moveTo(x + width / 2, y - depth + width * 0.25)
      ..lineTo(x + width, y - depth)
      ..lineTo(x + width, y - depth + height)
      ..lineTo(x + width / 2, y - depth + width * 0.25 + height)
      ..close();

    canvas.drawPath(leftPath, Paint()..color = leftColor);
    canvas.drawPath(rightPath, Paint()..color = rightColor);
    canvas.drawPath(topPath, Paint()..color = topColor);
  }

  void _drawCareerGrowth(Canvas canvas, Size size, double cx, double cy) {
    // Soft Background Ambient Radial Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 140));
    canvas.drawCircle(Offset(cx, cy), 140, glowPaint);

    // Step 1: Soft Orange Pastel Bar
    _drawIsometricBar(
      canvas,
      x: cx - 110,
      y: cy + 60,
      width: 50,
      height: 45,
      depth: 10,
      topColor: const Color(0xFFFFB74D),
      leftColor: const Color(0xFFFB8C00),
      rightColor: const Color(0xFFF57C00),
    );

    // Step 2: Sky Blue Bar
    _drawIsometricBar(
      canvas,
      x: cx - 50,
      y: cy + 40,
      width: 50,
      height: 75,
      depth: 15,
      topColor: const Color(0xFF4FC3F7),
      leftColor: const Color(0xFF0288D1),
      rightColor: const Color(0xFF01579B),
    );

    // Step 3: Pink/Magenta Bar
    _drawIsometricBar(
      canvas,
      x: cx + 10,
      y: cy + 20,
      width: 50,
      height: 105,
      depth: 20,
      topColor: const Color(0xFFF06292),
      leftColor: const Color(0xFFD81B60),
      rightColor: const Color(0xFFAD1457),
    );

    // Step 4: Highlighted Purple/Violet Bar (Top Peak)
    _drawIsometricBar(
      canvas,
      x: cx + 70,
      y: cy,
      width: 50,
      height: 135,
      depth: 25,
      topColor: const Color(0xFFB388FF),
      leftColor: const Color(0xFF7C4DFF),
      rightColor: const Color(0xFF651FFF),
    );

    // Floating 3D Isometric Trophy / Star Badge at the top
    final badgeCenter = Offset(cx + 95, cy - 75);
    final badgePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(badgeCenter, 22, badgePaint);
    canvas.drawCircle(
      badgeCenter,
      17,
      Paint()..color = const Color(0xFFFFB300),
    );

    // Star icon inside badge
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = i * 4 * math.pi / 5 - math.pi / 2;
      final a2 = (i * 4 + 2) * math.pi / 5 - math.pi / 2;
      final r1 = 11.0;
      final r2 = 5.0;
      final p1 = Offset(badgeCenter.dx + r1 * math.cos(a1), badgeCenter.dy + r1 * math.sin(a1));
      final p2 = Offset(badgeCenter.dx + r2 * math.cos(a2), badgeCenter.dy + r2 * math.sin(a2));
      if (i == 0) {
        starPath.moveTo(p1.dx, p1.dy);
      } else {
        starPath.lineTo(p1.dx, p1.dy);
      }
      starPath.lineTo(p2.dx, p2.dy);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = Colors.white);

    // Floating 3D UI Card (Left side)
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 120, cy - 65, 80, 50),
      const Radius.circular(12),
    );
    canvas.drawRRect(cardRect, Paint()..color = Colors.white.withValues(alpha: 0.95));
    // Line accents in card
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 110, cy - 55, 30, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8B7CF6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 110, cy - 42, 50, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFCBD5E1),
    );

    // Floating Decorative Isometric Plant (Right corner)
    final plantStem = Path()
      ..moveTo(cx - 130, cy + 80)
      ..cubicTo(cx - 135, cy + 60, cx - 125, cy + 50, cx - 130, cy + 40);
    canvas.drawPath(
      plantStem,
      Paint()
        ..color = const Color(0xFF34D399)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(cx - 135, cy + 45), 7, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(Offset(cx - 125, cy + 55), 6, Paint()..color = const Color(0xFF059669));
  }

  void _drawSkillTree(Canvas canvas, Size size, double cx, double cy) {
    // Skill Tree Nodes
    final p1 = Offset(cx, cy + 50);
    final p2 = Offset(cx - 60, cy - 10);
    final p3 = Offset(cx + 60, cy - 10);
    final p4 = Offset(cx - 80, cy - 70);
    final p5 = Offset(cx, cy - 80);
    final p6 = Offset(cx + 80, cy - 70);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, linePaint);
    canvas.drawLine(p1, p3, linePaint);
    canvas.drawLine(p2, p4, linePaint);
    canvas.drawLine(p2, p5, linePaint);
    canvas.drawLine(p3, p6, linePaint);

    void drawNode(Offset p, Color c, String label) {
      canvas.drawCircle(p, 20, Paint()..color = c);
      canvas.drawCircle(p, 15, Paint()..color = Colors.white.withValues(alpha: 0.9));
      canvas.drawCircle(p, 8, Paint()..color = c);
    }

    drawNode(p1, const Color(0xFFFF9800), 'Start');
    drawNode(p2, const Color(0xFF29B6F6), 'Code');
    drawNode(p3, const Color(0xFFEC407A), 'Design');
    drawNode(p4, const Color(0xFFAB47BC), 'AI');
    drawNode(p5, const Color(0xFF26A69A), 'Data');
    drawNode(p6, const Color(0xFF7E57C2), 'Lead');
  }

  void _drawCertificateLaptop(Canvas canvas, Size size, double cx, double cy) {
    // Isometric Laptop Base
    final base = Path()
      ..moveTo(cx - 90, cy + 30)
      ..lineTo(cx, cy + 65)
      ..lineTo(cx + 90, cy + 30)
      ..lineTo(cx, cy - 5)
      ..close();
    canvas.drawPath(base, Paint()..color = const Color(0xFFE2E8F0));

    // Isometric Laptop Screen
    final screen = Path()
      ..moveTo(cx - 70, cy + 10)
      ..lineTo(cx + 70, cy - 40)
      ..lineTo(cx + 70, cy - 110)
      ..lineTo(cx - 70, cy - 60)
      ..close();
    canvas.drawPath(screen, Paint()..color = const Color(0xFF1E1B4B));

    // Certificate glowing badge on screen
    canvas.drawCircle(Offset(cx, cy - 55), 24, Paint()..color = const Color(0xFF8B7CF6));
    canvas.drawCircle(Offset(cx, cy - 55), 18, Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(covariant _IsometricPainter oldDelegate) => oldDelegate.type != type;
}
