import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import '../models/pomodoro_settings.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroSettingsDialog extends ConsumerWidget {
  const PomodoroSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroProvider);
    final settings = pomodoroState.settings;

    return AppColors.withTheme(
      builder: (context, theme) => Dialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: theme.accent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Timer Settings',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Duration Settings Section
              _buildSectionHeader(theme, 'Duration'),
              const SizedBox(height: 16),
              _buildDurationSetting(
                theme,
                icon: Icons.work_rounded,
                label: 'Work Duration',
                value: settings.workDuration,
                onChanged: (value) {
                  if (value >= 1 && value <= 60) {
                    ref.read(pomodoroProvider.notifier).updateSettings(
                      settings.copyWith(workDuration: value),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDurationSetting(
                theme,
                icon: Icons.coffee_rounded,
                label: 'Short Break',
                value: settings.shortBreakDuration,
                onChanged: (value) {
                  if (value >= 1 && value <= 30) {
                    ref.read(pomodoroProvider.notifier).updateSettings(
                      settings.copyWith(shortBreakDuration: value),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDurationSetting(
                theme,
                icon: Icons.self_improvement_rounded,
                label: 'Long Break',
                value: settings.longBreakDuration,
                onChanged: (value) {
                  if (value >= 1 && value <= 45) {
                    ref.read(pomodoroProvider.notifier).updateSettings(
                      settings.copyWith(longBreakDuration: value),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32),
              // Behavior Settings Section
              _buildSectionHeader(theme, 'Behavior'),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                theme,
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref.read(pomodoroProvider.notifier).updateSettings(
                    settings.copyWith(soundEnabled: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                theme,
                icon: Icons.vibration_rounded,
                label: 'Vibration',
                value: settings.vibrationEnabled,
                onChanged: (value) {
                  ref.read(pomodoroProvider.notifier).updateSettings(
                    settings.copyWith(vibrationEnabled: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                theme,
                icon: Icons.play_circle_outline_rounded,
                label: 'Auto-start Breaks',
                value: settings.autoStartBreaks,
                onChanged: (value) {
                  ref.read(pomodoroProvider.notifier).updateSettings(
                    settings.copyWith(autoStartBreaks: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSwitchSetting(
                theme,
                icon: Icons.repeat_rounded,
                label: 'Auto-start Pomodoros',
                value: settings.autoStartPomodoros,
                onChanged: (value) {
                  ref.read(pomodoroProvider.notifier).updateSettings(
                    settings.copyWith(autoStartPomodoros: value),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.accent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDurationSetting(
    AppThemeData theme, {
    required IconData icon,
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => onChanged(value - 1),
              icon: Icon(Icons.remove, color: theme.textSecondary),
            ),
            Text(
              '$value min',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(Icons.add, color: theme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    AppThemeData theme, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.accent,
        ),
      ],
    );
  }
} 