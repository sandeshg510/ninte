import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class StatsGraph extends StatelessWidget {
  final List<double> data;
  final double height;
  final double barWidth;
  final double spacing;

  const StatsGraph({
    super.key,
    required this.data,
    this.height = 100,
    this.barWidth = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _StatsGraphPainter(
          data: data,
          barWidth: barWidth,
          spacing: spacing,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _StatsGraphPainter extends CustomPainter {
  final List<double> data;
  final double barWidth;
  final double spacing;

  _StatsGraphPainter({
    required this.data,
    required this.barWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Draw gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.accent,
        AppColors.accent.withOpacity(0.1),
      ],
    );

    paint.shader = gradient.createShader(rect);

    // Calculate bar positions
    final totalWidth = (barWidth * data.length) + (spacing * (data.length - 1));
    var startX = (size.width - totalWidth) / 2;

    // Draw bars
    for (var i = 0; i < data.length; i++) {
      final height = size.height * data[i];
      final top = size.height - height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, top, barWidth, height),
          const Radius.circular(4),
        ),
        paint,
      );

      startX += barWidth + spacing;
    }

    // Draw gradient overlay
    final overlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.accent.withOpacity(0.2),
        AppColors.accent.withOpacity(0.0),
      ],
    );

    paint.shader = overlayGradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 