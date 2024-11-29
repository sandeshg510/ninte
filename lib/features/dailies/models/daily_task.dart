import 'package:uuid/uuid.dart';

enum DailyPriority {
  low,
  medium,
  high,
  critical
}

enum DailyCategory {
  personal,
  work,
  health,
  study,
  fitness,
  shopping,
  other
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  final DateTime dueTime;
  final DailyPriority priority;
  final DailyCategory category;
  final bool isCompleted;
  final bool hasReminder;
  final int reminderMinutes;
  final DateTime createdAt;
  final List<DateTime> completionHistory;
  final int currentStreak;
  final int bestStreak;
  final Map<String, dynamic>? customData;

  DailyTask({
    String? id,
    required this.title,
    this.description = '',
    required this.dueTime,
    this.priority = DailyPriority.medium,
    this.category = DailyCategory.personal,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderMinutes = 15,
    DateTime? createdAt,
    this.completionHistory = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.customData,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  DailyTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueTime,
    DailyPriority? priority,
    DailyCategory? category,
    bool? isCompleted,
    bool? hasReminder,
    int? reminderMinutes,
    List<DateTime>? completionHistory,
    int? currentStreak,
    int? bestStreak,
    Map<String, dynamic>? customData,
  }) {
    return DailyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt,
      completionHistory: completionHistory ?? this.completionHistory,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      customData: customData ?? this.customData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueTime': dueTime.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
      'isCompleted': isCompleted,
      'hasReminder': hasReminder,
      'reminderMinutes': reminderMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'customData': customData,
    };
  }

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    // Helper function to parse priority
    DailyPriority _parsePriority(dynamic value) {
      if (value is int) {
        return DailyPriority.values[value];
      } else if (value is String) {
        return DailyPriority.values.firstWhere(
          (e) => e.toString().split('.').last == value,
          orElse: () => DailyPriority.medium,
        );
      }
      return DailyPriority.medium;
    }

    // Helper function to parse category
    DailyCategory _parseCategory(dynamic value) {
      if (value is int) {
        return DailyCategory.values[value];
      } else if (value is String) {
        return DailyCategory.values.firstWhere(
          (e) => e.toString().split('.').last == value,
          orElse: () => DailyCategory.personal,
        );
      }
      return DailyCategory.personal;
    }

    return DailyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueTime: DateTime.parse(json['dueTime'] as String),
      priority: _parsePriority(json['priority']),
      category: _parseCategory(json['category']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderMinutes: json['reminderMinutes'] as int? ?? 15,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completionHistory: (json['completionHistory'] as List<dynamic>?)
          ?.map((d) => DateTime.parse(d as String))
          .toList() ?? [],
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      customData: json['customData'] as Map<String, dynamic>?,
    );
  }

  bool get isOverdue {
    final now = DateTime.now();
    return !isCompleted && dueTime.isBefore(now);
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueTime.year == now.year && 
           dueTime.month == now.month && 
           dueTime.day == now.day;
  }

  String get priorityLabel {
    switch (priority) {
      case DailyPriority.low:
        return 'Low Priority';
      case DailyPriority.medium:
        return 'Medium Priority';
      case DailyPriority.high:
        return 'High Priority';
      case DailyPriority.critical:
        return 'Critical Priority';
    }
  }
} 