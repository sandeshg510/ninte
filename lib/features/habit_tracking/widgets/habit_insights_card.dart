import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';

class HabitInsightsCard extends ConsumerWidget {
  final List<Habit> habits;
  final List<Habit> completedToday;
  final ({int completed, int total, double percentage}) progress;
  final ({int current, int best}) streak;

  const HabitInsightsCard({
    super.key,
    required this.habits,
    required this.completedToday,
    required this.progress,
    required this.streak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Insights',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInsightItem(
                icon: Icons.trending_up_rounded,
                title: 'Completion Rate',
                value: '${(progress.percentage * 100).round()}%',
                color: AppColors.success,
              ),
              const SizedBox(width: 16),
              _buildInsightItem(
                icon: Icons.local_fire_department_rounded,
                title: 'Current Streak',
                value: '${streak.current} days',
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeDistribution(),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDistribution() {
    final morningHabits = habits.where((h) => 
      h.reminderTime != null && 
      h.reminderTime!.hour >= 5 && 
      h.reminderTime!.hour < 12
    ).length;
    
    final afternoonHabits = habits.where((h) => 
      h.reminderTime != null && 
      h.reminderTime!.hour >= 12 && 
      h.reminderTime!.hour < 17
    ).length;
    
    final eveningHabits = habits.where((h) => 
      h.reminderTime != null && 
      h.reminderTime!.hour >= 17 && 
      h.reminderTime!.hour < 22
    ).length;

    final total = morningHabits + afternoonHabits + eveningHabits;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Distribution',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              if (morningHabits > 0)
                Expanded(
                  flex: morningHabits,
                  child: Container(
                    height: 8,
                    color: AppColors.success,
                  ),
                ),
              if (afternoonHabits > 0)
                Expanded(
                  flex: afternoonHabits,
                  child: Container(
                    height: 8,
                    color: AppColors.warning,
                  ),
                ),
              if (eveningHabits > 0)
                Expanded(
                  flex: eveningHabits,
                  child: Container(
                    height: 8,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem('Morning', AppColors.success, morningHabits),
            _buildLegendItem('Afternoon', AppColors.warning, afternoonHabits),
            _buildLegendItem('Evening', AppColors.accent, eveningHabits),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 