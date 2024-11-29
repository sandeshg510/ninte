import '../models/daily_task.dart';

enum DailySortOption {
  dueTime,
  priority,
  alphabetical,
  category,
  completion
}

class DailyState {
  final List<DailyTask> dailyTasks;
  final bool isLoading;
  final String? error;
  final Map<String, Map<String, dynamic>> dailyStats;

  const DailyState({
    this.dailyTasks = const [],
    this.isLoading = true,
    this.error,
    this.dailyStats = const {},
  });

  List<DailyTask> get todayTasks {
    final now = DateTime.now();
    return dailyTasks.where((task) {
      final taskDate = DateTime(
        task.dueTime.year,
        task.dueTime.month,
        task.dueTime.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      return taskDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<DailyTask> get dueTasks {
    return todayTasks.where((task) => !task.isCompleted).toList();
  }

  List<DailyTask> get completedTasks {
    return todayTasks.where((task) => task.isCompleted).toList();
  }

  List<DailyTask> get overdueTasks => dailyTasks.where((task) => 
    task.isOverdue
  ).toList();

  List<DailyTask> getTasksByCategory(DailyCategory category) {
    return dailyTasks.where((task) => task.category == category).toList();
  }

  double get completionRateToday {
    final tasks = todayTasks;
    if (tasks.isEmpty) return 0.0;
    return completedTasks.length / tasks.length;
  }

  List<DailyTask> getSortedTasks(DailySortOption sortOption) {
    final tasks = List<DailyTask>.from(dailyTasks);
    
    tasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });

    switch (sortOption) {
      case DailySortOption.dueTime:
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.dueTime.compareTo(b.dueTime);
        });
        break;
      case DailySortOption.priority:
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.priority.index.compareTo(a.priority.index);
        });
        break;
      case DailySortOption.alphabetical:
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.title.compareTo(b.title);
        });
        break;
      case DailySortOption.category:
        tasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.category.name.compareTo(b.category.name);
        });
        break;
      case DailySortOption.completion:
        break;
    }
    return tasks;
  }

  DailyState copyWith({
    List<DailyTask>? dailyTasks,
    bool? isLoading,
    String? error,
    Map<String, Map<String, dynamic>>? dailyStats,
  }) {
    return DailyState(
      dailyTasks: dailyTasks ?? this.dailyTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }
} 