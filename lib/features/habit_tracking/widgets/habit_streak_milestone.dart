import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';

class HabitStreakMilestone extends StatelessWidget {
  final int streakDays;
  final VoidCallback onClose;

  const HabitStreakMilestone({
    super.key,
    required this.streakDays,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMilestoneIcon(),
              const SizedBox(height: 16),
              Text(
                _getMilestoneTitle(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getMilestoneMessage(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildStreakProgress(),
              const SizedBox(height: 16),
              _buildNextMilestone(),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getMilestoneIcon(),
        color: AppColors.accent,
        size: 48,
      ),
    );
  }

  IconData _getMilestoneIcon() {
    if (streakDays >= 100) return Icons.emoji_events;
    if (streakDays >= 30) return Icons.local_fire_department;
    if (streakDays >= 7) return Icons.star;
    return Icons.celebration;
  }

  String _getMilestoneTitle() {
    if (streakDays >= 100) return '🏆 Century Milestone!';
    if (streakDays >= 30) return '🔥 Monthly Milestone!';
    if (streakDays >= 7) return '⭐ Weekly Milestone!';
    return '🎉 Streak Started!';
  }

  String _getMilestoneMessage() {
    if (streakDays >= 100) {
      return 'Incredible! You\'ve maintained your habits for $streakDays days!';
    }
    if (streakDays >= 30) {
      return 'Amazing dedication! $streakDays days of consistent progress!';
    }
    if (streakDays >= 7) {
      return 'Great work! You\'ve completed $streakDays days in a row!';
    }
    return 'You\'ve started a streak! Keep going!';
  }

  Widget _buildStreakProgress() {
    final nextMilestone = _getNextMilestone();
    final progress = streakDays / nextMilestone;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$streakDays days',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              '$nextMilestone days',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildNextMilestone() {
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
          Icon(
            Icons.flag_rounded,
            color: AppColors.accent,
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Milestone',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_getNextMilestone() - streakDays} days to go',
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

  int _getNextMilestone() {
    if (streakDays < 7) return 7;
    if (streakDays < 30) return 30;
    if (streakDays < 100) return 100;
    return ((streakDays ~/ 100) + 1) * 100;
  }
} 