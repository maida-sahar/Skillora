import 'package:flutter/material.dart';

/// Official 4-color Google "G" logo vector widget matching Google Identity Guidelines.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    // Blue Path (#4285F4)
    final pathBlue = Path()
      ..moveTo(23.745, 12.27)
      ..cubicTo(23.745, 11.426, 23.669, 10.617, 23.53, 9.84)
      ..lineTo(12.0, 9.84)
      ..lineTo(12.0, 14.552)
      ..lineTo(18.583, 14.552)
      ..cubicTo(18.3, 16.08, 17.438, 17.375, 16.14, 18.243)
      ..lineTo(16.14, 21.31)
      ..lineTo(20.095, 21.31)
      ..cubicTo(22.409, 19.18, 23.745, 16.02, 23.745, 12.27)
      ..close();

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathBlue, paintBlue);

    // Green Path (#34A853)
    final pathGreen = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.96, 22.925, 19.95, 21.09)
      ..lineTo(16.14, 18.02)
      ..cubicTo(15.06, 18.745, 13.65, 19.18, 12.0, 19.18)
      ..cubicTo(8.875, 19.18, 6.228, 17.069, 5.28, 14.23)
      ..lineTo(1.23, 14.23)
      ..lineTo(1.23, 17.37)
      ..cubicTo(3.25, 21.39, 7.37, 24.0, 12.0, 24.0)
      ..close();

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathGreen, paintGreen);

    // Yellow Path (#FBBC05)
    final pathYellow = Path()
      ..moveTo(5.28, 14.23)
      ..cubicTo(5.038, 13.51, 4.9, 12.74, 4.9, 11.95)
      ..cubicTo(4.9, 11.16, 5.038, 10.39, 5.28, 9.67)
      ..lineTo(5.28, 6.53)
      ..lineTo(1.23, 6.53)
      ..cubicTo(0.445, 8.09, 0.0, 9.87, 0.0, 11.95)
      ..cubicTo(0.0, 14.03, 0.445, 15.81, 1.23, 17.37)
      ..lineTo(5.28, 14.23)
      ..close();

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathYellow, paintYellow);

    // Red Path (#EA4335)
    final pathRed = Path()
      ..moveTo(12.0, 4.75)
      ..cubicTo(13.76, 4.75, 15.34, 5.355, 16.58, 6.545)
      ..lineTo(20.03, 3.1)
      ..cubicTo(17.955, 1.16, 15.235, 0.0, 12.0, 0.0)
      ..cubicTo(7.37, 0.0, 3.25, 2.61, 1.23, 6.53)
      ..lineTo(5.28, 9.67)
      ..cubicTo(6.228, 6.831, 8.875, 4.75, 12.0, 4.75)
      ..close();

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pathRed, paintRed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
