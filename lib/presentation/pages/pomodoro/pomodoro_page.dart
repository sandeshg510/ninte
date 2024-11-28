import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/features/pomodoro/providers/pomodoro_provider.dart';
import 'package:ninte/features/pomodoro/models/pomodoro_timer.dart';
import 'package:ninte/features/pomodoro/widgets/pomodoro_settings_dialog.dart';
import 'package:ninte/features/pomodoro/widgets/timer_ring.dart';
import 'package:ninte/features/pomodoro/widgets/session_chip.dart';
import 'package:ninte/features/pomodoro/widgets/timer_controls.dart';
import 'package:ninte/features/pomodoro/widgets/session_stats.dart';
import 'package:ninte/features/pomodoro/widgets/timer_type_dialog.dart';
import 'background_pattern_painter.dart';

class PomodoroPage extends ConsumerStatefulWidget {
  const PomodoroPage({super.key});

  @override
  ConsumerState<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends ConsumerState<PomodoroPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double? _previousProgress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroState = ref.watch(pomodoroProvider);
    
    return AppColors.withTheme(
      builder: (context, theme) => Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          backgroundColor: theme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: theme.textPrimary),
              onPressed: () => _showSettingsDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Session Type Indicator using SessionChip
              SessionChip(
                type: pomodoroState.type,
                duration: _getSessionDuration(pomodoroState),
                isActive: pomodoroState.status == TimerStatus.running,
                onTap: () => _showTimerTypeDialog(context),
              ),
              
              // Timer Display with TimerRing
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Pattern
                    _buildBackgroundPattern(theme),
                    
                    // Timer Ring Widget
                    TimerRing(
                      progress: _getProgress(pomodoroState),
                      previousProgress: _previousProgress,
                      onProgressUpdate: (value) => _previousProgress = value,
                      status: pomodoroState.status,
                      theme: theme,
                    ),
                    
                    // Time Display
                    _buildTimeDisplay(theme, pomodoroState),
                  ],
                ),
              ),
              
              // Timer Controls Widget
              TimerControls(
                status: pomodoroState.status,
                onStart: () => ref.read(pomodoroProvider.notifier).startTimer(),
                onPause: () => ref.read(pomodoroProvider.notifier).pauseTimer(),
                onReset: () => ref.read(pomodoroProvider.notifier).resetTimer(),
                onSkip: () => ref.read(pomodoroProvider.notifier).skipSession(),
              ),
              
              const SizedBox(height: 24),
              
              // Session Stats Widget
              SessionStats(
                completedSessions: pomodoroState.completedSessions,
                totalMinutes: pomodoroState.completedSessions * pomodoroState.settings.workDuration,
                currentStreak: pomodoroState.currentStreak,
                bestStreak: pomodoroState.bestStreak,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(AppThemeData theme) {
    return CustomPaint(
      painter: BackgroundPatternPainter(
        color: theme.accent.withOpacity(0.03),
        progress: _animationController.value,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildTimeDisplay(AppThemeData theme, PomodoroState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: Text(
            _formatTime(state.remainingSeconds),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        
        // Status
        AnimatedOpacity(
          opacity: state.status == TimerStatus.running ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            state.status == TimerStatus.running ? 'FOCUS' : '',
            style: TextStyle(
              color: theme.accent,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress(PomodoroState state) {
    final totalSeconds = _getSessionDuration(state) * 60;
    return state.remainingSeconds / totalSeconds;
  }

  int _getSessionDuration(PomodoroState state) {
    switch (state.type) {
      case TimerType.work:
        return state.settings.workDuration;
      case TimerType.shortBreak:
        return state.settings.shortBreakDuration;
      case TimerType.longBreak:
        return state.settings.longBreakDuration;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PomodoroSettingsDialog(),
    );
  }

  void _showTimerTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TimerTypeDialog(),
    );
  }
} 