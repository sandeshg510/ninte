import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  BackgroundPatternPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    final numLines = (size.width / spacing).ceil();

    for (var i = 0; i < numLines; i++) {
      final x = i * spacing;
      final startY = size.height * (1 - progress);
      
      final path = Path()
        ..moveTo(x, startY)
        ..lineTo(x + spacing, size.height);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
} 