import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';

class HabitMilestoneCard extends StatelessWidget {
  final int currentStreak;
  final int streakGoal;

  const HabitMilestoneCard({
    super.key,
    required this.currentStreak,
    required this.streakGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have valid values for progress calculation
    final progress = streakGoal > 0 
        ? (currentStreak / streakGoal).clamp(0.0, 1.0)
        : 0.0;
    
    final remainingDays = streakGoal > currentStreak 
        ? streakGoal - currentStreak 
        : 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Milestone',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$streakGoal days',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remainingDays > 0 
                ? '$remainingDays days to go'
                : 'Milestone reached! 🎉',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 