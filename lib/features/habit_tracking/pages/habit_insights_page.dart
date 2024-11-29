import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_achievement_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_milestone_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_insights_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_streak_calendar.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';

class HabitInsightsPage extends ConsumerWidget {
  const HabitInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider).habits;
    final streak = ref.watch(streakProvider);
    final progress = ref.watch(todayProgressProvider);
    final categoryStats = ref.read(habitProvider.notifier).getCategoryCompletion();
    final weeklyStats = ref.read(habitProvider.notifier).getWeeklyStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Insights & Achievements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Insights
            HabitInsightsCard(
              habits: habits,
              completedToday: ref.watch(completedHabitsProvider),
              progress: progress,
              streak: streak,
            ),
            const SizedBox(height: 24),

            // Streak Milestones
            Text(
              'Streak Milestones',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            HabitMilestoneCard(
              currentStreak: streak.current,
              streakGoal: streak.best,
            ),
            const SizedBox(height: 24),

            // Category Performance
            Text(
              'Category Performance',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryPerformance(categoryStats),
            const SizedBox(height: 24),

            // Weekly Analysis
            Text(
              'Weekly Analysis',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyAnalysis(weeklyStats),
            const SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievements(streak.current, streak.best),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance(Map<HabitCategory, double> categoryStats) {
    return AppCard(
      child: Column(
        children: categoryStats.entries.map((entry) {
          final percentage = (entry.value * 100).round();
          return Column(
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(entry.key),
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyAnalysis(Map<String, dynamic> weeklyStats) {
    return AppCard(
      child: Column(
        children: [
          _buildStatRow(
            'Total Completions',
            '${weeklyStats['completions']}',
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Average Per Day',
            '${weeklyStats['averagePerDay'].toStringAsFixed(1)}',
            Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Best Day',
            weeklyStats['bestDay'],
            Icons.star_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(int currentStreak, int bestStreak) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (currentStreak >= 7)
          HabitAchievementCard(
            achievement: '7 Day Streak',
            description: 'Completed all habits for 7 days straight!',
            icon: Icons.local_fire_department,
          ),
        if (currentStreak >= 30)
          HabitAchievementCard(
            achievement: 'Monthly Master',
            description: 'Maintained habits for a full month!',
            icon: Icons.calendar_month,
          ),
        if (bestStreak >= 100)
          HabitAchievementCard(
            achievement: 'Centurion',
            description: 'Achieved a 100-day streak!',
            icon: Icons.military_tech,
          ),
        // Add more achievements as needed
      ],
    );
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.favorite;
      case HabitCategory.productivity:
        return Icons.lightbulb;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.mindfulness:
        return Icons.self_improvement;
      case HabitCategory.social:
        return Icons.people;
      case HabitCategory.other:
        return Icons.category;
    }
  }
} 