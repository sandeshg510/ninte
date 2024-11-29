import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:intl/intl.dart';

class HabitStreakCalendar extends ConsumerWidget {
  final Habit habit;
  final int daysToShow;

  const HabitStreakCalendar({
    super.key,
    required this.habit,
    this.daysToShow = 30,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final days = List.generate(daysToShow, (index) {
      return today.subtract(Duration(days: daysToShow - 1 - index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Calendar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isCompleted = habit.completedDates.any((d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              return Tooltip(
                message: '${DateFormat('MMM d').format(date)}: ${isCompleted ? 'Completed' : 'Not completed'}',
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accent
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: AppColors.surface,
                          size: 12,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 