import '../models/habit.dart';

class HabitState {
  final List<Habit> habits;
  final List<Habit> archivedHabits;
  final bool isLoading;
  final String? error;
  final Map<String, Map<String, dynamic>> habitStats;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastCompletionDate;

  const HabitState({
    this.habits = const [],
    this.archivedHabits = const [],
    this.isLoading = true,
    this.error,
    this.habitStats = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastCompletionDate,
  });

  List<Habit> get dueHabits => habits.where((h) => h.isDueToday).toList();
  
  List<Habit> get completedToday => habits.where((h) {
    final now = DateTime.now();
    return h.completedDates.any((date) => 
      date.year == now.year && 
      date.month == now.month && 
      date.day == now.day);
  }).toList();

  List<Habit> getHabitsByCategory(HabitCategory category) {
    return habits.where((h) => h.category == category).toList();
  }

  double get completionRateToday {
    if (habits.isEmpty) return 0.0;
    return completedToday.length / habits.length;
  }

  HabitState copyWith({
    List<Habit>? habits,
    List<Habit>? archivedHabits,
    bool? isLoading,
    String? error,
    Map<String, Map<String, dynamic>>? habitStats,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastCompletionDate,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      archivedHabits: archivedHabits ?? this.archivedHabits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      habitStats: habitStats ?? this.habitStats,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
    );
  }
} 