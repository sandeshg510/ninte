import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/features/pomodoro/models/pomodoro_timer.dart';
import 'package:ninte/features/pomodoro/providers/pomodoro_provider.dart';

class TimerTypeDialog extends ConsumerStatefulWidget {
  const TimerTypeDialog({super.key});

  @override
  ConsumerState<TimerTypeDialog> createState() => _TimerTypeDialogState();
}

class _TimerTypeDialogState extends ConsumerState<TimerTypeDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroState = ref.watch(pomodoroProvider);

    return AppColors.withTheme(
      builder: (context, theme) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Timer Type',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._buildTimerOptions(context, ref, theme, pomodoroState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTimerOptions(
    BuildContext context,
    WidgetRef ref,
    AppThemeData theme,
    PomodoroState state,
  ) {
    final options = [
      (TimerType.work, 'Work Session', Icons.work_rounded),
      (TimerType.shortBreak, 'Short Break', Icons.coffee_rounded),
      (TimerType.longBreak, 'Long Break', Icons.self_improvement_rounded),
    ];

    return List.generate(
      options.length,
      (index) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTimerTypeOption(
            context,
            ref,
            theme,
            type: options[index].$1,
            title: options[index].$2,
            subtitle: _getDurationText(state, options[index].$1),
            icon: options[index].$3,
          ),
        ),
      ),
    );
  }

  String _getDurationText(PomodoroState state, TimerType type) {
    switch (type) {
      case TimerType.work:
        return '${state.settings.workDuration} minutes';
      case TimerType.shortBreak:
        return '${state.settings.shortBreakDuration} minutes';
      case TimerType.longBreak:
        return '${state.settings.longBreakDuration} minutes';
    }
  }

  Widget _buildTimerTypeOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeData theme, {
    required TimerType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = ref.watch(pomodoroProvider).type == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(pomodoroProvider.notifier).setTimerType(type);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? theme.accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.accent.withOpacity(0.2) : theme.surfaceLight.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.accent : theme.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? theme.accent : theme.textPrimary,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 