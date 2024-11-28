import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' show max;
import 'dart:developer' as dev;
import '../services/sound_service.dart';
import '../services/notification_service.dart';
import '../services/pomodoro_firestore_service.dart';
import '../models/pomodoro_timer.dart';
import 'providers.dart';

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  final SoundService _soundService;
  final PomodoroFirestoreService _firestoreService = PomodoroFirestoreService();
  Timer? _timer;
  Timer? _syncTimer;
  bool _isInitialized = false;
  int _elapsedSeconds = 0;

  // Add constant for minimum session duration
  static const int _minimumSessionMinutes = 10;

  PomodoroNotifier(this._soundService) : super(PomodoroState.initial()) {
    _initializeState();
    PomodoroNotificationService.init();
  }

  Future<void> _initializeState() async {
    if (_isInitialized) return;
    
    try {
      state = state.copyWith(isLoading: true);
      dev.log('Initializing Pomodoro state...');
      
      // First load settings
      final settings = await _firestoreService.loadSettings();
      if (settings != null) {
        dev.log('Loaded settings from Firebase: ${settings.toString()}');
        state = state.copyWith(
          settings: settings,
          remainingSeconds: settings.workDuration * 60, // Update initial time based on loaded settings
        );
      }
      
      // Then load stats
      final stats = await _firestoreService.getSessionStats();
      if (stats != null) {
        state = state.copyWith(
          dailySessions: (stats['dailySessions'] as num?)?.toInt() ?? 0,
          dailyMinutes: (stats['dailyMinutes'] as num?)?.toInt() ?? 0,
          totalSessions: (stats['totalSessions'] as num?)?.toInt() ?? 0,
          totalMinutes: (stats['totalMinutes'] as num?)?.toInt() ?? 0,
          currentStreak: (stats['currentStreak'] as num?)?.toInt() ?? 0,
          bestStreak: (stats['bestStreak'] as num?)?.toInt() ?? 0,
          lastSessionDate: stats['lastSessionDate'] != null 
              ? DateTime.parse(stats['lastSessionDate'] as String)
              : null,
          isLoading: false,
        );
        dev.log('Successfully loaded stats: ${stats.toString()}');
      } else {
        state = state.copyWith(isLoading: false);
      }
      
      _isInitialized = true;
      _startPeriodicSync();
      _checkForDayChange();
      
      // Log loaded state
      _logSettingsState();
    } catch (e) {
      dev.log('Error initializing state: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Add method to check and handle day changes
  void _checkForDayChange() async {
    final now = DateTime.now();
    final lastSessionDate = state.lastSessionDate;

    if (lastSessionDate != null && 
        (now.year != lastSessionDate.year || 
         now.month != lastSessionDate.month || 
         now.day != lastSessionDate.day)) {
      // Reset daily stats
      final newState = state.copyWith(
        dailySessions: 0,
        dailyMinutes: 0,
        lastSessionDate: now,
      );
      state = newState;
      await _saveToFirebase(newState);
      dev.log('Daily stats reset for new day');
    }
  }

  void _updateSessionStats() {
    final now = DateTime.now();
    final lastSessionDate = state.lastSessionDate;
    
    // If it's a new day, reset daily counts
    if (lastSessionDate != null && lastSessionDate.day != now.day) {
      state = state.copyWith(
        dailySessions: 1, // Start with 1 for the current session
        dailyMinutes: state.settings.workDuration,
        totalSessions: state.totalSessions + 1,
        totalMinutes: state.totalMinutes + state.settings.workDuration,
        lastSessionDate: now,
      );
    } else {
      // Same day, increment daily and total counts
      state = state.copyWith(
        dailySessions: state.dailySessions + 1,
        dailyMinutes: state.dailyMinutes + state.settings.workDuration,
        totalSessions: state.totalSessions + 1,
        totalMinutes: state.totalMinutes + state.settings.workDuration,
        lastSessionDate: now,
      );
    }
  }

  // Update PomodoroState to include daily stats
  Future<void> _saveToFirebase(PomodoroState currentState) async {
    try {
      dev.log('Saving session data to Firebase...');
      dev.log('Stats to save: Daily Sessions=${currentState.dailySessions}, Daily Minutes=${currentState.dailyMinutes}, Total Sessions=${currentState.totalSessions}, Total Minutes=${currentState.totalMinutes}');
      
      await _firestoreService.saveSessionStats(
        dailySessions: currentState.dailySessions,
        dailyMinutes: currentState.dailyMinutes,
        totalSessions: currentState.totalSessions,
        totalMinutes: currentState.totalMinutes,
        currentStreak: currentState.currentStreak,
        bestStreak: currentState.bestStreak,
        lastSessionDate: currentState.lastSessionDate,
      );
      dev.log('Successfully saved session data to Firebase');
    } catch (e) {
      dev.log('Error saving to Firebase: $e');
    }
  }

  // Add periodic sync method
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 1), // Sync every minute
      (_) {
        dev.log('Running periodic sync...');
        _saveToFirebase(state);
      },
    );
    dev.log('Started periodic sync timer');
  }

  // Update dispose to clean up sync timer
  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel(); // Clean up sync timer
    PomodoroNotificationService.cancelAll();
    super.dispose();
  }

  Future<void> _loadFromFirebase() async {
    try {
      dev.log('Loading data from Firebase...');
      final stats = await _firestoreService.getSessionStats();
      if (stats != null) {
        state = state.copyWith(
          dailySessions: stats['dailySessions'] ?? 0,
          dailyMinutes: stats['dailyMinutes'] ?? 0,
          totalSessions: stats['totalSessions'] ?? 0,
          totalMinutes: stats['totalMinutes'] ?? 0,
          currentStreak: stats['currentStreak'] ?? 0,
          bestStreak: stats['bestStreak'] ?? 0,
          lastSessionDate: stats['lastSessionDate'] != null 
              ? DateTime.parse(stats['lastSessionDate']) 
              : null,
        );
        dev.log('Successfully loaded data from Firebase');
      }
    } catch (e) {
      dev.log('Error loading from Firebase: $e');
    }
  }

  // Add method to force sync
  Future<void> syncWithFirebase() async {
    try {
      dev.log('Starting manual sync...');
      final stats = await _firestoreService.getSessionStats();
      
      if (stats != null) {
        state = state.copyWith(
          dailySessions: max(state.dailySessions, (stats['dailySessions'] as num?)?.toInt() ?? 0),
          dailyMinutes: max(state.dailyMinutes, (stats['dailyMinutes'] as num?)?.toInt() ?? 0),
          totalSessions: max(state.totalSessions, (stats['totalSessions'] as num?)?.toInt() ?? 0),
          totalMinutes: max(state.totalMinutes, (stats['totalMinutes'] as num?)?.toInt() ?? 0),
          currentStreak: max(state.currentStreak, (stats['currentStreak'] as num?)?.toInt() ?? 0),
          bestStreak: max(state.bestStreak, (stats['bestStreak'] as num?)?.toInt() ?? 0),
          lastSessionDate: stats['lastSessionDate'] != null 
              ? DateTime.parse(stats['lastSessionDate'] as String)
              : state.lastSessionDate,
        );
        
        await _saveToFirebase(state);
        dev.log('Manual sync completed successfully');
      }
    } catch (e) {
      dev.log('Error during manual sync: $e');
    }
  }

  void _updateStreak() {
    final now = DateTime.now();
    final lastSessionDate = state.lastSessionDate;
    
    if (lastSessionDate == null) {
      state = state.copyWith(
        currentStreak: 1,
        bestStreak: 1,
        lastSessionDate: now,
      );
      return;
    }

    // Check if the last session was yesterday or today
    final isConsecutiveDay = now.difference(lastSessionDate).inDays <= 1;
    final isSameDay = now.year == lastSessionDate.year && 
                     now.month == lastSessionDate.month && 
                     now.day == lastSessionDate.day;
    
    if (isConsecutiveDay) {
      if (!isSameDay) {
        // New day, increment streak
        final newStreak = state.currentStreak + 1;
        state = state.copyWith(
          currentStreak: newStreak,
          bestStreak: newStreak > state.bestStreak ? newStreak : state.bestStreak,
          lastSessionDate: now,
        );
        
        // Log milestone
        if (newStreak > 0 && newStreak % 7 == 0) {
          dev.log('🎉 Achieved ${newStreak}-day streak!');
        }
      }
    } else {
      // Break in streak
      state = state.copyWith(
        currentStreak: 1,
        lastSessionDate: now,
      );
      dev.log('Streak reset after ${now.difference(lastSessionDate).inDays} days');
    }
  }

  void _tickTimer() {
    if (state.remainingSeconds > 0) {
      if (state.remainingSeconds <= 3) {
        _soundService.playTick();
      }
      
      // Update elapsed time
      if (state.type == TimerType.work) {
        _elapsedSeconds++;
        
        // Update minutes every 60 seconds
        if (_elapsedSeconds % 60 == 0) {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
            dailyMinutes: state.dailyMinutes + 1,
            totalMinutes: state.totalMinutes + 1,
          );
          
          // Save to Firebase every 5 minutes
          if (_elapsedSeconds % 300 == 0) { // 300 seconds = 5 minutes
            _saveToFirebase(state);
            dev.log('Updated minutes in Firebase: ${_elapsedSeconds ~/ 60} minutes elapsed');
          }
        } else {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
          );
        }
      } else {
        // For break sessions, just update remaining time
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      }
    } else {
      _timer?.cancel();
      _soundService.playTimerComplete();
      _elapsedSeconds = 0;
      
      if (state.type == TimerType.work) {
        // Calculate total elapsed minutes for this session
        final elapsedMinutes = state.settings.workDuration;
        
        // Only count if minimum duration met
        if (elapsedMinutes >= _minimumSessionMinutes) {
          final newState = state.copyWith(
            status: TimerStatus.finished,
            dailySessions: state.dailySessions + 1,
            totalSessions: state.totalSessions + 1,
            dailyMinutes: state.dailyMinutes + elapsedMinutes,
            totalMinutes: state.totalMinutes + elapsedMinutes,
          );
          state = newState;
          _saveToFirebase(newState);
          
          // Handle auto-start break
          if (state.settings.autoStartBreaks) {
            final shouldTakeLongBreak = state.dailySessions % state.settings.sessionsBeforeLongBreak == 0;
            final nextType = shouldTakeLongBreak ? TimerType.longBreak : TimerType.shortBreak;
            
            dev.log('Auto-starting ${shouldTakeLongBreak ? "long" : "short"} break');
            Future.delayed(const Duration(seconds: 1), () {
              setTimerType(nextType);
              startTimer();
            });
          }
        }
      } else {
        // Break session completed
        state = state.copyWith(
          status: TimerStatus.finished,
        );
        
        // Handle auto-start work session
        if (state.settings.autoStartPomodoros) {
          dev.log('Auto-starting next work session');
          Future.delayed(const Duration(seconds: 1), () {
            setTimerType(TimerType.work);
            startTimer();
          });
        }
      }
      
      // Show appropriate notification
      if (state.type == TimerType.work) {
        PomodoroNotificationService.showWorkCompleteNotification();
      } else {
        PomodoroNotificationService.showBreakCompleteNotification();
      }
    }
  }

  // Add session analytics
  void _logSessionAnalytics({
    required int duration,
    required bool wasSkipped,
    required bool metThreshold,
  }) {
    dev.log('''
      Session Analytics:
      - Duration: $duration minutes
      - Was Skipped: $wasSkipped
      - Met Threshold: $metThreshold
      - Type: ${state.type}
      - Daily Sessions: ${state.dailySessions}
      - Total Sessions: ${state.totalSessions}
      ''');
  }

  // Improve skip session with feedback
  void skipSession() {
    _timer?.cancel();
    
    if (state.type == TimerType.work && state.status == TimerStatus.running) {
      final elapsedMinutes = (state.settings.workDuration * 60 - state.remainingSeconds) ~/ 60;
      
      if (elapsedMinutes >= _minimumSessionMinutes) {
        final newState = state.copyWith(
          remainingSeconds: 0,
          status: TimerStatus.finished,
          dailySessions: state.dailySessions + 1,
          totalSessions: state.totalSessions + 1,
          dailyMinutes: state.dailyMinutes + elapsedMinutes,
          totalMinutes: state.totalMinutes + elapsedMinutes,
          lastSessionDate: DateTime.now(),
        );
        state = newState;
        _saveToFirebase(newState);
        
        _logSessionAnalytics(
          duration: elapsedMinutes,
          wasSkipped: true,
          metThreshold: true,
        );
        
        PomodoroNotificationService.showWorkCompleteNotification();
      } else {
        _logSessionAnalytics(
          duration: elapsedMinutes,
          wasSkipped: true,
          metThreshold: false,
        );
        
        state = state.copyWith(
          remainingSeconds: 0,
          status: TimerStatus.finished,
        );
      }
    } else {
      state = state.copyWith(
        remainingSeconds: 0,
        status: TimerStatus.finished,
      );
    }
    
    _soundService.playTimerComplete();
  }

  // Add auto-break feature
  void _handleSessionCompletion() {
    if (state.type == TimerType.work) {
      // Determine next break type
      final completedSessions = state.dailySessions + 1;
      final shouldTakeLongBreak = completedSessions % state.settings.sessionsBeforeLongBreak == 0;
      
      if (state.settings.autoStartBreaks) {
        // Auto start appropriate break
        setTimerType(shouldTakeLongBreak ? TimerType.longBreak : TimerType.shortBreak);
        startTimer();
      } else {
        // Suggest break type
        final breakType = shouldTakeLongBreak ? 'long' : 'short';
        dev.log('Suggesting $breakType break after $completedSessions sessions');
      }
    } else if (state.type == TimerType.shortBreak || state.type == TimerType.longBreak) {
      if (state.settings.autoStartPomodoros) {
        setTimerType(TimerType.work);
        startTimer();
      }
    }
  }

  void startTimer() {
    if (state.status == TimerStatus.running) return;

    // If timer was finished, reset it before starting
    if (state.status == TimerStatus.finished || state.remainingSeconds == 0) {
      _elapsedSeconds = 0;
      state = state.copyWith(
        remainingSeconds: _getSessionDuration(),
        status: TimerStatus.initial,
      );
    }

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickTimer(),
    );
    
    state = state.copyWith(status: TimerStatus.running);
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
    _soundService.playTick();
    
    // Save progress when paused
    if (state.type == TimerType.work) {
      _saveToFirebase(state);
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _soundService.playReset();
    
    state = state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: _getSessionDuration(),
    );
  }

  // Helper method to get session duration in seconds
  int _getSessionDuration() {
    switch (state.type) {
      case TimerType.work:
        return state.settings.workDuration * 60;
      case TimerType.shortBreak:
        return state.settings.shortBreakDuration * 60;
      case TimerType.longBreak:
        return state.settings.longBreakDuration * 60;
    }
  }

  void setTimerType(TimerType type) {
    _timer?.cancel();
    dev.log('Switching timer type to: $type');
    
    state = state.copyWith(
      type: type,
      status: TimerStatus.initial,
      remainingSeconds: type == TimerType.work 
          ? state.settings.workDuration * 60
          : type == TimerType.shortBreak 
              ? state.settings.shortBreakDuration * 60
              : state.settings.longBreakDuration * 60,
    );
  }

  // Add this method to manually refresh data
  Future<void> refreshData() async {
    await _loadFromFirebase();
  }

  Future<void> updateSettings(PomodoroTimer newSettings) async {
    try {
      dev.log('Updating timer settings...');
      
      if (!_validateSettings(newSettings)) {
        dev.log('Invalid settings provided');
        return;
      }

      // Save to Firebase first
      await _firestoreService.saveSettings(newSettings);
      
      // Then update local state
      final newRemainingSeconds = state.type == TimerType.work
          ? newSettings.workDuration * 60
          : state.type == TimerType.shortBreak
              ? newSettings.shortBreakDuration * 60
              : newSettings.longBreakDuration * 60;

      state = state.copyWith(
        settings: newSettings,
        remainingSeconds: state.status == TimerStatus.running
            ? state.remainingSeconds
            : newRemainingSeconds,
      );

      dev.log('Timer settings updated and saved successfully');
      _verifySettings();
    } catch (e) {
      dev.log('Error updating settings: $e');
    }
  }

  // Helper method to validate settings
  bool _validateSettings(PomodoroTimer settings) {
    return settings.workDuration > 0 &&
           settings.shortBreakDuration > 0 &&
           settings.longBreakDuration > 0 &&
           settings.workDuration <= 60 &&
           settings.shortBreakDuration <= 30 &&
           settings.longBreakDuration <= 45;
  }

  // Add method to load settings
  Future<void> _loadSettings() async {
    try {
      final settings = await _firestoreService.loadSettings();
      if (settings != null) {
        state = state.copyWith(settings: settings);
        dev.log('Settings loaded successfully');
      }
    } catch (e) {
      dev.log('Error loading settings: $e');
    }
  }

  // Add debug method to check settings
  void _logSettingsState() {
    dev.log('''
      Current Settings State:
      - Auto-start breaks: ${state.settings.autoStartBreaks}
      - Auto-start pomodoros: ${state.settings.autoStartPomodoros}
      - Work duration: ${state.settings.workDuration}
      - Short break duration: ${state.settings.shortBreakDuration}
      - Long break duration: ${state.settings.longBreakDuration}
      - Sessions before long break: ${state.settings.sessionsBeforeLongBreak}
    ''');
  }

  // Add method to verify settings are loaded
  void _verifySettings() {
    dev.log('''
      Settings Verification:
      Work Duration: ${state.settings.workDuration}
      Short Break: ${state.settings.shortBreakDuration}
      Long Break: ${state.settings.longBreakDuration}
      Auto-start Breaks: ${state.settings.autoStartBreaks}
      Auto-start Pomodoros: ${state.settings.autoStartPomodoros}
    ''');
  }
}

class PomodoroState {
  final TimerStatus status;
  final TimerType type;
  final int remainingSeconds;
  final int dailySessions;
  final int dailyMinutes;
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastSessionDate;
  final PomodoroTimer settings;
  final bool isLoading;

  const PomodoroState({
    required this.status,
    required this.type,
    required this.remainingSeconds,
    this.dailySessions = 0,
    this.dailyMinutes = 0,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastSessionDate,
    required this.settings,
    this.isLoading = false,
  });

  factory PomodoroState.initial() => PomodoroState(
    status: TimerStatus.initial,
    type: TimerType.work,
    remainingSeconds: const PomodoroTimer().workDuration * 60,
    dailySessions: 0,
    dailyMinutes: 0,
    totalSessions: 0,
    totalMinutes: 0,
    settings: const PomodoroTimer(), // This will be updated when settings load
    isLoading: true, // Start with loading state
  );

  PomodoroState copyWith({
    TimerStatus? status,
    TimerType? type,
    int? remainingSeconds,
    int? dailySessions,
    int? dailyMinutes,
    int? totalSessions,
    int? totalMinutes,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastSessionDate,
    PomodoroTimer? settings,
    bool? isLoading,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      type: type ?? this.type,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      dailySessions: dailySessions ?? this.dailySessions,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return PomodoroNotifier(soundService);
}); 