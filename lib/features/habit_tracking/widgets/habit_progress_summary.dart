import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';

class HabitProgressSummary extends ConsumerWidget {
  const HabitProgressSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider).habits;
    final dailyHabits = habits.where((h) => h.frequency == HabitFrequency.daily).toList();
    final weeklyHabits = habits.where((h) => h.frequency == HabitFrequency.weekly).toList();
    final monthlyHabits = habits.where((h) => h.frequency == HabitFrequency.monthly).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (dailyHabits.isNotEmpty)
              Expanded(
                child: _buildProgressIndicator(
                  label: "Today",
                  total: dailyHabits.length,
                  completed: _getCompletedToday(dailyHabits),
                  icon: Icons.today_rounded,
                ),
              ),
            if (weeklyHabits.isNotEmpty) ...[
              _buildVerticalDivider(),
              Expanded(
                child: _buildProgressIndicator(
                  label: "Week",
                  total: weeklyHabits.length,
                  completed: _getCompletedThisWeek(weeklyHabits),
                  icon: Icons.view_week_rounded,
                ),
              ),
            ],
            if (monthlyHabits.isNotEmpty) ...[
              _buildVerticalDivider(),
              Expanded(
                child: _buildProgressIndicator(
                  label: "Month",
                  total: monthlyHabits.length,
                  completed: _getCompletedThisMonth(monthlyHabits),
                  icon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required String label,
    required int total,
    required int completed,
    required IconData icon,
  }) {
    final progress = total > 0 ? completed / total : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              backgroundColor: AppColors.accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              strokeWidth: 3,
            ),
            Icon(
              icon,
              size: 16,
              color: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$completed/$total',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: VerticalDivider(
        color: AppColors.accent.withOpacity(0.1),
        thickness: 1,
        width: 1,
      ),
    );
  }

  int _getCompletedToday(List<Habit> habits) {
    final now = DateTime.now();
    return habits.where((habit) {
      return habit.completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
    }).length;
  }

  int _getCompletedThisWeek(List<Habit> habits) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return habits.where((habit) {
      return habit.completedDates.any((date) =>
        date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(now.add(const Duration(days: 1))));
    }).length;
  }

  int _getCompletedThisMonth(List<Habit> habits) {
    final now = DateTime.now();
    return habits.where((habit) {
      return habit.completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month);
    }).length;
  }
} 