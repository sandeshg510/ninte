import 'package:uuid/uuid.dart';

enum HabitFrequency {
  daily,
  weekly,
  monthly,
  custom
}

enum HabitCategory {
  health,
  productivity,
  learning,
  fitness,
  mindfulness,
  social,
  other
}

class Habit {
  final String id;
  final String name;
  final String description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final int currentStreak;
  final int bestStreak;
  final bool isArchived;
  final Map<String, dynamic>? customData;

  Habit({
    String? id,
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    this.completedDates = const [],
    DateTime? createdAt,
    this.reminderTime,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.isArchived = false,
    this.customData,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'frequency': frequency.name,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'isArchived': isArchived,
      'customData': customData,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: HabitCategory.values.byName(json['category']),
      frequency: HabitFrequency.values.byName(json['frequency']),
      completedDates: (json['completedDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      reminderTime: json['reminderTime'] != null 
          ? DateTime.parse(json['reminderTime']) 
          : null,
      currentStreak: json['currentStreak'],
      bestStreak: json['bestStreak'],
      isArchived: json['isArchived'],
      customData: json['customData'],
    );
  }

  int get expectedCompletions {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays;
    
    switch (frequency) {
      case HabitFrequency.daily:
        return daysSinceCreation + 1;
      case HabitFrequency.weekly:
        return ((daysSinceCreation + 1) / 7).ceil();
      case HabitFrequency.monthly:
        return ((daysSinceCreation + 1) / 30).ceil();
      case HabitFrequency.custom:
        return 1; // Default for custom frequency
    }
  }

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if already completed today
    final completedToday = completedDates.any((date) {
      final completionDate = DateTime(date.year, date.month, date.day);
      return completionDate.isAtSameMomentAs(today);
    });
    
    if (completedToday) return false;
    
    // Check if due based on frequency
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final lastCompletion = completedDates.isEmpty ? null : completedDates.last;
        if (lastCompletion == null) return true;
        return !lastCompletion.isAfter(weekStart);
      case HabitFrequency.monthly:
        final monthStart = DateTime(today.year, today.month, 1);
        final lastCompletion = completedDates.isEmpty ? null : completedDates.last;
        if (lastCompletion == null) return true;
        return !lastCompletion.isAfter(monthStart);
      case HabitFrequency.custom:
        return true; // Custom frequency is always due
    }
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    DateTime? reminderTime,
    int? currentStreak,
    int? bestStreak,
    bool? isArchived,
    Map<String, dynamic>? customData,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      isArchived: isArchived ?? this.isArchived,
      customData: customData ?? this.customData,
    );
  }
} 