class PomodoroSettings {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });
} 