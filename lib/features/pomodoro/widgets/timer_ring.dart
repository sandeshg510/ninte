import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/features/pomodoro/models/pomodoro_timer.dart';

class TimerRing extends StatelessWidget {
  final double progress;
  final double? previousProgress;
  final ValueChanged<double> onProgressUpdate;
  final TimerStatus status;
  final AppThemeData theme;

  const TimerRing({
    super.key,
    required this.progress,
    required this.previousProgress,
    required this.onProgressUpdate,
    required this.status,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: previousProgress ?? progress,
        end: progress,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      onEnd: () => onProgressUpdate(progress),
      builder: (context, animatedProgress, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.surfaceLight.withOpacity(0.1),
                  width: 24,
                ),
              ),
            ),
            // Progress ring
            SizedBox(
              width: 280,
              height: 280,
              child: CircularProgressIndicator(
                value: animatedProgress,
                strokeWidth: 24,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  status == TimerStatus.running
                      ? theme.accent
                      : theme.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
            // Inner glow
            if (status == TimerStatus.running)
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
} 