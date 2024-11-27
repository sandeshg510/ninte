import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class ProgressChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String title;
  final double maxValue;
  final bool showLabels;

  const ProgressChart({
    super.key,
    required this.data,
    required this.labels,
    required this.title,
    this.maxValue = 100,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.surfaceLight.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildChart(theme),
            ),
            if (showLabels) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  labels.length,
                  (index) => Text(
                    labels[index],
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(AppThemeData theme) {
    return CustomPaint(
      painter: ChartPainter(
        data: data,
        maxValue: maxValue,
        lineColor: theme.accent,
        fillColor: theme.accent.withOpacity(0.1),
        gridColor: theme.surfaceLight.withOpacity(0.1),
        labelColor: theme.textSecondary,
      ),
      size: const Size(double.infinity, 200),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;

  ChartPainter({
    required this.data,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (data.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final xStep = size.width / (data.length - 1);
    final yStep = size.height / maxValue;

    path.moveTo(0, size.height - (data[0] * yStep));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (data[0] * yStep));

    for (var i = 1; i < data.length; i++) {
      final x = xStep * i;
      final y = size.height - (data[i] * yStep);
      
      final prevX = xStep * (i - 1);
      final prevY = size.height - (data[i - 1] * yStep);
      
      final controlX1 = prevX + (x - prevX) / 2;
      final controlX2 = x - (x - prevX) / 2;
      
      path.cubicTo(
        controlX1, prevY,
        controlX2, y,
        x, y,
      );
      
      fillPath.cubicTo(
        controlX1, prevY,
        controlX2, y,
        x, y,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      final x = xStep * i;
      final y = size.height - (data[i] * yStep);

      canvas.drawCircle(
        Offset(x, y),
        4,
        pointPaint,
      );

      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()
          ..color = lineColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 