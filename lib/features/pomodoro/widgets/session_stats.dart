import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class SessionStats extends StatelessWidget {
  final int dailySessions;
  final int dailyMinutes;
  final int totalSessions;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;

  const SessionStats({
    super.key,
    required this.dailySessions,
    required this.dailyMinutes,
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Column(
        children: [
          // Daily Stats
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.surfaceLight.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      theme,
                      icon: Icons.check_circle_outline_rounded,
                      value: dailySessions.toString(),
                      label: 'Sessions',
                    ),
                    _buildDivider(theme),
                    _buildStat(
                      theme,
                      icon: Icons.timer_outlined,
                      value: '$dailyMinutes',
                      label: 'Minutes',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total Stats
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.surfaceLight.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Progress',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      theme,
                      icon: Icons.check_circle_outline_rounded,
                      value: totalSessions.toString(),
                      label: 'Sessions',
                    ),
                    _buildDivider(theme),
                    _buildStat(
                      theme,
                      icon: Icons.timer_outlined,
                      value: '$totalMinutes',
                      label: 'Minutes',
                    ),
                    _buildDivider(theme),
                    _buildStat(
                      theme,
                      icon: Icons.local_fire_department_rounded,
                      value: currentStreak.toString(),
                      label: 'Streak',
                      subtitle: 'Best: $bestStreak',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.surfaceLight,
    );
  }

  Widget _buildStat(
    AppThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    String? subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: theme.accent),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 14,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
} 