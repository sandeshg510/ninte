import 'package:flutter/material.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class HabitStreakCalendar extends StatelessWidget {
  final Habit habit;

  const HabitStreakCalendar({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(30, (index) {
      return now.subtract(Duration(days: 29 - index));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 30 Days',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isCompleted = habit.completedDates.any((d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day);
              final isToday = date.year == now.year &&
                             date.month == now.month &&
                             date.day == now.day;

              return _buildDateCell(date, isCompleted, isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(DateTime date, bool isCompleted, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (isCompleted)
            Center(
              child: Icon(
                Icons.check_rounded,
                color: AppColors.accent,
                size: 16,
              ),
            ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color: isCompleted 
                    ? AppColors.accent
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 