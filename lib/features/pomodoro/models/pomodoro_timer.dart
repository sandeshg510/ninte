import 'package:flutter/foundation.dart';

enum TimerStatus {
  initial,   // Timer hasn't started
  running,   // Timer is running
  paused,    // Timer is paused
  finished   // Timer completed
}

enum TimerType {
  work,      // Work session
  shortBreak, // Short break
  longBreak  // Long break
}

class PomodoroTimer {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const PomodoroTimer({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });

  PomodoroTimer copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
  }) {
    return PomodoroTimer(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
    );
  }
} 