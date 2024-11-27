import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<double> trendData;
  final bool showTrend;
  final double progress;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.trendData = const [],
    this.showTrend = true,
    this.progress = 0.0,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showTrend && trendData.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _buildTrendIndicator(theme),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress > 0) ...[
              const SizedBox(height: 16),
              _buildProgressBar(theme),
            ],
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
              ),
            ),
            if (showTrend && trendData.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: _buildTrendGraph(theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(AppThemeData theme) {
    final isPositive = trendData.last > trendData.first;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: isPositive ? theme.success : theme.error,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${((trendData.last - trendData.first) / trendData.first * 100).abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: isPositive ? theme.success : theme.error,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (value * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.accent, theme.accentLight],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ((1 - value) * 100).toInt(),
                    child: const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendGraph(AppThemeData theme) {
    return CustomPaint(
      painter: TrendGraphPainter(
        data: trendData,
        lineColor: theme.accent,
        fillColor: theme.accent.withOpacity(0.1),
      ),
    );
  }
}

class TrendGraphPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  TrendGraphPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = max - min;

    final xStep = size.width / (data.length - 1);
    final yStep = size.height / range;

    path.moveTo(0, size.height - (data[0] - min) * yStep);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (data[0] - min) * yStep);

    for (var i = 1; i < data.length; i++) {
      final x = xStep * i;
      final y = size.height - (data[i] - min) * yStep;
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 