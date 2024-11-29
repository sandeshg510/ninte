import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../services/habit_firestore_service.dart';
import '../models/habit.dart';
import 'habit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitNotifier extends StateNotifier<HabitState> {
  final HabitFirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _habitsSubscription;
  StreamSubscription? _archivedHabitsSubscription;

  static const _gracePeriodHours = 24;

  HabitNotifier(this._firestoreService) : super(const HabitState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          error: 'Please sign in to access habits',
          isLoading: false,
        );
        return;
      }
      
      // Listen to habits stream
      _habitsSubscription = _firestoreService.getHabits().listen(
        (habits) {
          state = state.copyWith(
            habits: habits,
            isLoading: false,
            error: null,
          );
          _loadHabitStats();
        },
        onError: (error) {
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
        },
      );

      // Listen to archived habits stream
      _archivedHabitsSubscription = _firestoreService.getArchivedHabits().listen(
        (archivedHabits) {
          state = state.copyWith(
            archivedHabits: archivedHabits,
            isLoading: false,
            error: null,
          );
        },
        onError: (error) {
          dev.log('Error loading archived habits: $error');
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createHabit(Habit habit) async {
    try {
      await _firestoreService.createHabit(habit);
      
      if (state.currentStreak > 0) {
        final now = DateTime.now();
        final lastCompletion = state.lastCompletionDate;
        
        if (lastCompletion != null) {
          final hoursSinceLastCompletion = now.difference(lastCompletion).inHours;
          
          // Only reset streak if grace period has passed
          if (hoursSinceLastCompletion > _gracePeriodHours) {
            state = state.copyWith(
              currentStreak: 0,
              lastCompletionDate: null,
            );
            await _firestoreService.updateStreaks(
              currentStreak: 0,
              bestStreak: state.bestStreak,
            );
            dev.log('Streak reset: Grace period exceeded for new habit');
          }
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _firestoreService.updateHabit(habit);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestoreService.deleteHabit(habitId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await _firestoreService.archiveHabit(habitId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markHabitComplete(String habitId) async {
    try {
      await _firestoreService.markHabitComplete(habitId);
      await _loadHabitStats();
      
      final now = DateTime.now();
      final allHabitsCompleted = _areAllHabitsCompletedToday();
      
      if (allHabitsCompleted) {
        final lastDate = state.lastCompletionDate;
        
        if (lastDate == null) {
          // First completion - start streak
          _updateStreak(1);
        } else if (_isSameDay(lastDate, now)) {
          // Already completed today - maintain current streak
          return;
        } else if (_isConsecutiveDay(lastDate, now) || 
                   (_isWithinGracePeriod(lastDate) && !_isSameDay(lastDate, now))) {
          // Either consecutive day or within grace period
          _updateStreak(state.currentStreak + 1);
        } else {
          // Streak broken - start new streak
          _updateStreak(1);
        }
        
        dev.log('Updated streak: ${state.currentStreak} (all habits completed)');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _loadHabitStats() async {
    try {
      final newStats = <String, Map<String, dynamic>>{};
      
      for (final habit in state.habits) {
        final stats = await _firestoreService.getHabitStats(habit.id);
        newStats[habit.id] = stats;
      }
      
      state = state.copyWith(habitStats: newStats);
    } catch (e) {
      dev.log('Error loading habit stats: $e');
    }
  }

  Future<void> unarchiveHabit(String habitId) async {
    try {
      await _firestoreService.unarchiveHabit(habitId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    _archivedHabitsSubscription?.cancel();
    super.dispose();
  }

  bool _areAllHabitsCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeHabits = state.habits.where((h) => !h.isArchived).toList();
    
    if (activeHabits.isEmpty) return false;
    
    return activeHabits.every((habit) {
      return habit.completedDates.any((date) {
        final completionDate = DateTime(date.year, date.month, date.day);
        return completionDate.isAtSameMomentAs(today);
      });
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    final local1 = date1.toLocal();
    final local2 = date2.toLocal();
    
    return local1.year == local2.year &&
           local1.month == local2.month &&
           local1.day == local2.day;
  }

  bool _isConsecutiveDay(DateTime lastDate, DateTime currentDate) {
    final local1 = lastDate.toLocal();
    final local2 = currentDate.toLocal();
    
    // Get dates without time
    final date1 = DateTime(local1.year, local1.month, local1.day);
    final date2 = DateTime(local2.year, local2.month, local2.day);
    
    final difference = date2.difference(date1).inDays;
    return difference == 1; // Strictly check for consecutive days
  }

  bool _isWithinGracePeriod(DateTime lastDate) {
    final now = DateTime.now().toLocal();
    final lastLocal = lastDate.toLocal();
    
    // Allow completion until 4 AM the next day
    final gracePeriodEnd = DateTime(
      lastLocal.year,
      lastLocal.month,
      lastLocal.day + 1,
      4, // 4 AM grace period
    );
    
    return now.isBefore(gracePeriodEnd);
  }

  Future<void> _updateStreak(int newStreak) async {
    final newBestStreak = newStreak > state.bestStreak ? newStreak : state.bestStreak;
    
    state = state.copyWith(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastCompletionDate: DateTime.now(),
    );
    
    await _firestoreService.updateStreaks(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );
    
    // Check for milestone
    if (newStreak > 0 && newStreak % 7 == 0) {
      dev.log('🎉 Achieved ${newStreak}-day streak milestone!');
    }
  }

  void _startStreakCheck() {
    Timer.periodic(const Duration(hours: 1), (_) {
      _checkStreakStatus();
    });
  }

  void _checkStreakStatus() {
    final now = DateTime.now();
    final lastDate = state.lastCompletionDate;
    
    if (lastDate != null && !_isWithinGracePeriod(lastDate) && 
        !_isSameDay(lastDate, now) && state.currentStreak > 0) {
      // Streak broken - reset
      _updateStreak(0);
      dev.log('Streak reset due to missed day');
    }
  }

  void checkAndSendReminders() {
    final now = DateTime.now();
    final incompleteHabits = state.habits.where((habit) {
      return !habit.isArchived && 
             !habit.completedDates.any((date) => 
                date.year == now.year && 
                date.month == now.month && 
                date.day == now.day);
    }).toList();

    if (incompleteHabits.isNotEmpty && state.currentStreak > 0) {
      // Send reminder notification to protect streak
      dev.log('Sending reminder for ${incompleteHabits.length} incomplete habits');
    }
  }

  Map<String, dynamic> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final weeklyCompletions = state.habits.map((habit) {
      return habit.completedDates.where((date) => 
        date.isAfter(weekStart) && 
        date.isBefore(now.add(const Duration(days: 1)))
      ).length;
    }).fold<int>(0, (sum, count) => sum + count);

    return {
      'completions': weeklyCompletions,
      'averagePerDay': weeklyCompletions / 7,
      'bestDay': _getBestDayOfWeek(),
    };
  }

  Future<void> checkStreakRecovery() async {
    if (state.currentStreak == 0 && state.lastCompletionDate != null) {
      final now = DateTime.now();
      final daysMissed = now.difference(state.lastCompletionDate!).inDays;
      
      if (daysMissed == 1 && _areAllHabitsCompletedToday()) {
        // Allow streak recovery if only one day was missed
        final newStreak = state.bestStreak + 1;
        state = state.copyWith(
          currentStreak: newStreak,
          bestStreak: max(newStreak, state.bestStreak),
        );
        await _firestoreService.updateStreaks(
          currentStreak: newStreak,
          bestStreak: state.bestStreak,
        );
        dev.log('Streak recovered after missing one day');
      }
    }
  }

  Map<HabitCategory, double> getCategoryCompletion() {
    final categoryStats = <HabitCategory, double>{};
    
    for (final category in HabitCategory.values) {
      final habits = state.habits.where((h) => h.category == category).toList();
      if (habits.isEmpty) continue;
      
      final completionRate = habits
          .map((h) => h.completedDates.length / h.expectedCompletions)
          .reduce((a, b) => a + b) / habits.length;
          
      categoryStats[category] = completionRate;
    }
    
    return categoryStats;
  }

  String _getBestDayOfWeek() {
    final weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final completionsByDay = List.filled(7, 0);
    
    for (final habit in state.habits) {
      for (final date in habit.completedDates) {
        final weekday = date.weekday - 1; // 0-6 for Monday-Sunday
        completionsByDay[weekday]++;
      }
    }
    
    int maxCompletions = 0;
    int bestDayIndex = 0;
    
    for (int i = 0; i < completionsByDay.length; i++) {
      if (completionsByDay[i] > maxCompletions) {
        maxCompletions = completionsByDay[i];
        bestDayIndex = i;
      }
    }
    
    return weekDays[bestDayIndex];
  }

  int max(int a, int b) => a > b ? a : b;
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  return HabitNotifier(HabitFirestoreService());
});

// Convenience providers
final dueHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitProvider).dueHabits;
});

final completedHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitProvider).completedToday;
});

final habitCompletionRateProvider = Provider<double>((ref) {
  return ref.watch(habitProvider).completionRateToday;
});

// Provider for habits by category
final habitsByCategoryProvider = Provider.family<List<Habit>, HabitCategory>((ref, category) {
  return ref.watch(habitProvider).getHabitsByCategory(category);
});

// Provider for habit statistics
final habitStatsProvider = Provider.family<Map<String, dynamic>?, String>((ref, habitId) {
  return ref.watch(habitProvider).habitStats[habitId];
});

// Provider for streak information
final streakProvider = Provider<({int current, int best})>((ref) {
  final state = ref.watch(habitProvider);
  return (
    current: state.currentStreak,
    best: state.bestStreak,
  );
});

// Provider for loading state
final habitLoadingProvider = Provider<bool>((ref) {
  return ref.watch(habitProvider).isLoading;
});

// Provider for error state
final habitErrorProvider = Provider<String?>((ref) {
  return ref.watch(habitProvider).error;
});

// Provider for today's progress
final todayProgressProvider = Provider<({int completed, int total, double percentage})>((ref) {
  final state = ref.watch(habitProvider);
  final completed = state.completedToday.length;
  final total = state.habits.length;
  final percentage = total > 0 ? completed / total : 0.0;
  
  return (
    completed: completed,
    total: total,
    percentage: percentage,
  );
});

// Provider for archived habits
final archivedHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitProvider).archivedHabits;
});

// Provider for habit reminders
final habitRemindersProvider = Provider<List<Habit>>((ref) {
  final now = DateTime.now();
  return ref.watch(habitProvider).habits.where((habit) {
    if (habit.reminderTime == null) return false;
    return habit.reminderTime!.hour == now.hour && 
           habit.reminderTime!.minute == now.minute;
  }).toList();
});

// Provider for habit categories with counts
final habitCategoriesProvider = Provider<List<({HabitCategory category, int count})>>((ref) {
  final habits = ref.watch(habitProvider).habits;
  final categories = HabitCategory.values;
  
  return categories.map((category) {
    final count = habits.where((h) => h.category == category).length;
    return (category: category, count: count);
  }).toList();
});

// Provider for habit search
final habitSearchProvider = Provider.family<List<Habit>, String>((ref, query) {
  if (query.isEmpty) return ref.watch(habitProvider).habits;
  
  final lowercaseQuery = query.toLowerCase();
  return ref.watch(habitProvider).habits.where((habit) {
    return habit.name.toLowerCase().contains(lowercaseQuery) ||
           habit.description.toLowerCase().contains(lowercaseQuery);
  }).toList();
});
  