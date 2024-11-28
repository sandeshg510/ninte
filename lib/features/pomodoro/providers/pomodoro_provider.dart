import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/pomodoro_timer.dart';
import '../models/pomodoro_settings.dart';
import '../services/sound_service.dart';
import 'sound_provider.dart';

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  final SoundService _soundService;
  Timer? _timer;
  
  PomodoroNotifier(this._soundService) : super(PomodoroState.initial());

  void startTimer() {
    if (state.status == TimerStatus.running) return;

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickTimer(),
    );

    _soundService.playStart();
    state = state.copyWith(status: TimerStatus.running);
  }

  void pauseTimer() {
    _timer?.cancel();
    _soundService.playPause();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resetTimer() {
    _timer?.cancel();
    _soundService.playReset();
    state = PomodoroState.initial();
  }

  void _tickTimer() {
    if (state.remainingSeconds > 0) {
      if (state.remainingSeconds <= 3) {
        _soundService.playTick();
      }
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );
    } else {
      _timer?.cancel();
      _soundService.playTimerComplete();
      state = state.copyWith(
        status: TimerStatus.finished,
        completedSessions: state.completedSessions + 1,
      );
      // TODO: Handle session completion
    }
  }

  void updateSettings(PomodoroTimer newSettings) {
    state = state.copyWith(settings: newSettings);
    // Reset timer if needed
    if (state.status != TimerStatus.running) {
      resetTimer();
    }
  }

  void setTimerType(TimerType type) {
    _timer?.cancel();
    state = state.copyWith(
      type: type,
      remainingSeconds: type == TimerType.work 
        ? state.settings.workDuration * 60
        : type == TimerType.shortBreak 
          ? state.settings.shortBreakDuration * 60
          : state.settings.longBreakDuration * 60,
      status: TimerStatus.initial,
    );
  }

  void skipSession() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: 0,
      status: TimerStatus.finished,
      completedSessions: state.completedSessions + 1,
    );
    _soundService.playTimerComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class PomodoroState {
  final TimerStatus status;
  final TimerType type;
  final int remainingSeconds;
  final int completedSessions;
  final int currentStreak;
  final int bestStreak;
  final PomodoroTimer settings;

  const PomodoroState({
    required this.status,
    required this.type,
    required this.remainingSeconds,
    required this.completedSessions,
    this.currentStreak = 0,
    this.bestStreak = 0,
    required this.settings,
  });

  factory PomodoroState.initial() => PomodoroState(
    status: TimerStatus.initial,
    type: TimerType.work,
    remainingSeconds: const PomodoroTimer().workDuration * 60,
    completedSessions: 0,
    currentStreak: 0,
    bestStreak: 0,
    settings: const PomodoroTimer(),
  );

  PomodoroState copyWith({
    TimerStatus? status,
    TimerType? type,
    int? remainingSeconds,
    int? completedSessions,
    int? currentStreak,
    int? bestStreak,
    PomodoroTimer? settings,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      settings: settings ?? this.settings,
    );
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return PomodoroNotifier(soundService);
}); 