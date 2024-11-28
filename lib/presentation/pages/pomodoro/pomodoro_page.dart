import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show min;
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
import 'package:ninte/features/pomodoro/widgets/stats_shimmer.dart';

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
    final size = MediaQuery.of(context).size;
    
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
              icon: Icon(Icons.sync, color: theme.textPrimary),
              onPressed: () => ref.read(pomodoroProvider.notifier).syncWithFirebase(),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: theme.textPrimary),
              onPressed: () => _showSettingsDialog(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Session Type Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SessionChip(
                  type: pomodoroState.type,
                  duration: _getSessionDuration(pomodoroState),
                  isActive: pomodoroState.status == TimerStatus.running,
                  onTap: () => _showTimerTypeDialog(context),
                ),
              ),
              
              // Timer Display
              Container(
                height: size.width * 0.8, // Make it proportional to screen width
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Timer Ring
                      SizedBox(
                        width: size.width * 0.7,
                        height: size.width * 0.7,
                        child: TimerRing(
                          progress: _getProgress(pomodoroState),
                          previousProgress: _previousProgress,
                          onProgressUpdate: (value) => _previousProgress = value,
                          status: pomodoroState.status,
                          theme: theme,
                        ),
                      ),
                      
                      // Time Display
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(pomodoroState.remainingSeconds),
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          if (pomodoroState.status == TimerStatus.running)
                            Text(
                              'FOCUS',
                              style: TextStyle(
                                color: theme.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 4,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Timer Controls
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TimerControls(
                  status: pomodoroState.status,
                  onStart: () => ref.read(pomodoroProvider.notifier).startTimer(),
                  onPause: () => ref.read(pomodoroProvider.notifier).pauseTimer(),
                  onReset: () => ref.read(pomodoroProvider.notifier).resetTimer(),
                  onSkip: () => ref.read(pomodoroProvider.notifier).skipSession(),
                ),
              ),
              
              // Session Stats
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: pomodoroState.isLoading
                    ? const StatsShimmer()
                    : SessionStats(
                        dailySessions: pomodoroState.dailySessions,
                        dailyMinutes: pomodoroState.dailyMinutes,
                        totalSessions: pomodoroState.totalSessions,
                        totalMinutes: pomodoroState.totalMinutes,
                        currentStreak: pomodoroState.currentStreak,
                        bestStreak: pomodoroState.bestStreak,
                      ),
              ),
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

  // Update TimerRing widget to handle proper sizing
  Widget _buildTimerRing(AppThemeData theme, PomodoroState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size,
          height: size,
          child: TimerRing(
            progress: _getProgress(state),
            previousProgress: _previousProgress,
            onProgressUpdate: (value) => _previousProgress = value,
            status: state.status,
            theme: theme,
          ),
        );
      },
    );
  }
} 