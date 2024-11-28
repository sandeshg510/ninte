import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/features/pomodoro/models/pomodoro_timer.dart';

class SessionChip extends StatelessWidget {
  final TimerType type;
  final int duration;
  final bool isActive;
  final VoidCallback onTap;

  const SessionChip({
    super.key,
    required this.type,
    required this.duration,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? theme.accent.withOpacity(0.1)
                : theme.surfaceLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? theme.accent.withOpacity(0.2)
                  : theme.surfaceLight.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(),
                color: isActive ? theme.accent : theme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getLabel(),
                style: TextStyle(
                  color: isActive ? theme.accent : theme.textSecondary,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.surfaceLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$duration min',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case TimerType.work:
        return Icons.work_rounded;
      case TimerType.shortBreak:
        return Icons.coffee_rounded;
      case TimerType.longBreak:
        return Icons.self_improvement_rounded;
    }
  }

  String _getLabel() {
    switch (type) {
      case TimerType.work:
        return 'Work';
      case TimerType.shortBreak:
        return 'Short Break';
      case TimerType.longBreak:
        return 'Long Break';
    }
  }
} 