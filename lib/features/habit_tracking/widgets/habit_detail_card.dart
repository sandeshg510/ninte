import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_streak_calendar.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_stats_card.dart';

class HabitDetailCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitDetailCard({
    super.key,
    required this.habit,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                habit.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_rounded, color: AppColors.textSecondary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_rounded, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
          if (habit.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              habit.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
          const SizedBox(height: 24),
          HabitStreakCalendar(habit: habit),
          const SizedBox(height: 24),
          HabitStatsCard(habitId: habit.id),
          const SizedBox(height: 16),
          _buildReminderSection(context),
        ],
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    if (habit.reminderTime == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Reminder',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                TimeOfDay.fromDateTime(habit.reminderTime!).format(context),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 