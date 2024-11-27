import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class CircularProgress extends StatelessWidget {
  final double progress;
  final String label;
  final String value;
  final double size;
  final double strokeWidth;
  final bool showAnimation;
  final bool showCenterContent;

  const CircularProgress({
    super.key,
    required this.progress,
    this.label = '',
    this.value = '',
    this.size = 100,
    this.strokeWidth = 10,
    this.showAnimation = true,
    this.showCenterContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Circle
            CustomPaint(
              size: Size(size, size),
              painter: CircularProgressPainter(
                progress: 1.0,
                progressColor: theme.surfaceLight.withOpacity(0.2),
                strokeWidth: strokeWidth,
              ),
            ),
            // Progress Circle
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: Duration(milliseconds: showAnimation ? 1500 : 0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: CircularProgressPainter(
                    progress: value,
                    progressColor: theme.accent,
                    strokeWidth: strokeWidth,
                    gradient: LinearGradient(
                      colors: [
                        theme.accent,
                        theme.accentLight,
                      ],
                      transform: GradientRotation(math.pi / 4),
                    ),
                  ),
                );
              },
            ),
            // Center Content
            if (showCenterContent) ...[
              Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: theme.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: theme.accent,
                    size: size * 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final Gradient? gradient;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paint.shader = gradient!.createShader(rect);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 