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
    DateTime? createdAt,
    this.completionHistory = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.customData,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  DailyTask copyWith({
    String? title,
    String? description,
    DateTime? dueTime,
    DailyPriority? priority,
    DailyCategory? category,
    bool? isCompleted,
    List<DateTime>? completionHistory,
    int? currentStreak,
    int? bestStreak,
    Map<String, dynamic>? customData,
  }) {
    return DailyTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
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
      'priority': priority.name,
      'category': category.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'customData': customData,
    };
  }

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueTime: DateTime.parse(json['dueTime']),
      priority: DailyPriority.values.byName(json['priority']),
      category: DailyCategory.values.byName(json['category']),
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      completionHistory: (json['completionHistory'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      currentStreak: json['currentStreak'],
      bestStreak: json['bestStreak'],
      customData: json['customData'],
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