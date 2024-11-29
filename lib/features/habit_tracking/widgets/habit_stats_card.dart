import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';

class HabitStatsCard extends ConsumerWidget {
  final String habitId;

  const HabitStatsCard({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider(habitId));

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Current Streak',
                value: '${stats['currentStreak']} days',
                color: AppColors.accent,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.emoji_events_rounded,
                label: 'Best Streak',
                value: '${stats['bestStreak']} days',
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.calendar_today_rounded,
                label: 'This Month',
                value: '${stats['thisMonth']} times',
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.history_rounded,
                label: 'Last Month',
                value: '${stats['lastMonth']} times',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: Icons.check_circle_outline_rounded,
            label: 'Total Completions',
            value: '${stats['totalCompletions']} times',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    bool fullWidth = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.textSecondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
} 