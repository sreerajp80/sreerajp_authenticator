import 'package:flutter/material.dart';

class EnhancedPatternPainter extends CustomPainter {
  final bool isDark;

  EnhancedPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linesPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.blue.shade100.withValues(alpha: 0.3)
      ..strokeWidth = isDark ? 0.8 : 0.6
      ..style = PaintingStyle.stroke;

    const spacing = 25.0;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linesPaint,
      );
    }

    final crossHatchPaint = Paint()
      ..color = isDark
          ? Colors.blue.withValues(alpha: 0.06)
          : Colors.indigo.withValues(alpha: 0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width + size.height; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i - size.height, 0),
        crossHatchPaint,
      );
    }

    final dotsPaint = Paint()
      ..color = isDark
          ? Colors.blue.shade200.withValues(alpha: 0.2)
          : Colors.blue.shade200.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const dotSpacing = 35.0;
    const dotRadius = 1.2;

    for (double x = dotRadius; x < size.width; x += dotSpacing) {
      for (double y = dotRadius; y < size.height; y += dotSpacing) {
        final offsetX = (x.hashCode % 3 - 1) * 0.5;
        final offsetY = (y.hashCode % 3 - 1) * 0.5;
        canvas.drawCircle(
          Offset(x + offsetX, y + offsetY),
          dotRadius,
          dotsPaint,
        );
      }
    }

    final circlePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.blue.shade50.withValues(alpha: 0.15)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      12,
      circlePaint,
    );

    final meshPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              isDark
                  ? Colors.blue.withValues(alpha: 0.12)
                  : Colors.indigo.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            radius: 0.5,
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width, 0),
              radius: size.width * 0.3,
            ),
          );

    canvas.drawCircle(Offset(size.width, 0), size.width * 0.3, meshPaint);

    if (isDark) {
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.02),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
