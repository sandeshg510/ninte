import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import '../models/pomodoro_timer.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroSettingsDialog extends ConsumerStatefulWidget {
  const PomodoroSettingsDialog({super.key});

  @override
  ConsumerState<PomodoroSettingsDialog> createState() => _PomodoroSettingsDialogState();
}

class _PomodoroSettingsDialogState extends ConsumerState<PomodoroSettingsDialog> {
  // Local state to track slider values
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;
  Timer? _debounceTimer;

  // Updated duration limits
  static const _durationLimits = {
    'work': {
      'min': 15,    // Minimum 15 minutes
      'max': 60,    // Maximum 60 minutes
      'default': 25 // Default 25 minutes
    },
    'shortBreak': {
      'min': 3,     // Minimum 3 minutes
      'max': 30,    // Updated: Maximum 30 minutes (was 15)
      'default': 5  // Default 5 minutes
    },
    'longBreak': {
      'min': 15,    // Minimum 15 minutes
      'max': 45,    // Updated: Maximum 45 minutes (was 60)
      'default': 15 // Default 15 minutes
    },
  };

  // Local state for behaviors
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late bool _autoStartBreaks;
  late bool _autoStartPomodoros;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroProvider).settings;
    _workDuration = settings.workDuration;
    _shortBreakDuration = settings.shortBreakDuration;
    _longBreakDuration = settings.longBreakDuration;
    _soundEnabled = settings.soundEnabled;
    _vibrationEnabled = settings.vibrationEnabled;
    _autoStartBreaks = settings.autoStartBreaks;
    _autoStartPomodoros = settings.autoStartPomodoros;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Debounced settings update
  void _debouncedUpdateSettings(PomodoroTimer newSettings) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(pomodoroProvider.notifier).updateSettings(newSettings);
    });
  }

  Widget _buildDurationSetting(
    AppThemeData theme, {
    required IconData icon,
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$value min',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$minValue',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.accent,
                  inactiveTrackColor: theme.surfaceLight,
                  thumbColor: theme.accent,
                  overlayColor: theme.accent.withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                    elevation: 2,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: minValue.toDouble(),
                  max: maxValue.toDouble(),
                  divisions: maxValue - minValue,
                  onChanged: (newValue) {
                    HapticFeedback.selectionClick();
                    onChanged(newValue.round());
                  },
                ),
              ),
            ),
            Text(
              '$maxValue',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateSettings(PomodoroTimer newSettings) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(pomodoroProvider.notifier).updateSettings(newSettings);
    });
  }

  Widget _buildBehaviorSetting(
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
        Switch.adaptive(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.selectionClick();
            onChanged(newValue);
          },
          activeColor: theme.accent,
          activeTrackColor: theme.accent.withOpacity(0.3),
          inactiveThumbColor: theme.textSecondary,
          inactiveTrackColor: theme.surfaceLight.withOpacity(0.3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroProvider).settings;

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
                value: _workDuration,
                minValue: _durationLimits['work']!['min']!,
                maxValue: _durationLimits['work']!['max']!,
                onChanged: (value) {
                  setState(() => _workDuration = value);
                  _debouncedUpdateSettings(
                    settings.copyWith(workDuration: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDurationSetting(
                theme,
                icon: Icons.coffee_rounded,
                label: 'Short Break',
                value: _shortBreakDuration,
                minValue: _durationLimits['shortBreak']!['min']!,
                maxValue: _durationLimits['shortBreak']!['max']!,
                onChanged: (value) {
                  setState(() => _shortBreakDuration = value);
                  _debouncedUpdateSettings(
                    settings.copyWith(shortBreakDuration: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDurationSetting(
                theme,
                icon: Icons.self_improvement_rounded,
                label: 'Long Break',
                value: _longBreakDuration,
                minValue: _durationLimits['longBreak']!['min']!,
                maxValue: _durationLimits['longBreak']!['max']!,
                onChanged: (value) {
                  setState(() => _longBreakDuration = value);
                  _debouncedUpdateSettings(
                    settings.copyWith(longBreakDuration: value),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              // Behavior Settings Section
              _buildSectionHeader(theme, 'Behavior'),
              const SizedBox(height: 16),
              _buildBehaviorSetting(
                theme,
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  _updateSettings(settings.copyWith(soundEnabled: value));
                },
              ),
              const SizedBox(height: 16),
              _buildBehaviorSetting(
                theme,
                icon: Icons.vibration_rounded,
                label: 'Vibration',
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
                  _updateSettings(settings.copyWith(vibrationEnabled: value));
                },
              ),
              const SizedBox(height: 16),
              _buildBehaviorSetting(
                theme,
                icon: Icons.play_circle_outline_rounded,
                label: 'Auto-start Breaks',
                value: _autoStartBreaks,
                onChanged: (value) {
                  setState(() => _autoStartBreaks = value);
                  _updateSettings(settings.copyWith(autoStartBreaks: value));
                },
              ),
              const SizedBox(height: 16),
              _buildBehaviorSetting(
                theme,
                icon: Icons.repeat_rounded,
                label: 'Auto-start Pomodoros',
                value: _autoStartPomodoros,
                onChanged: (value) {
                  setState(() => _autoStartPomodoros = value);
                  _updateSettings(settings.copyWith(autoStartPomodoros: value));
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
} 