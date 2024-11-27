import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

enum TimePeriod { day, week, month }

class PeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final Function(TimePeriod) onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Container(
        height: 36,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.surfaceLight.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(theme, TimePeriod.day, 'Day'),
            _buildOption(theme, TimePeriod.week, 'Week'),
            _buildOption(theme, TimePeriod.month, 'Month'),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(AppThemeData theme, TimePeriod period, String label) {
    final isSelected = selected == period;
    return GestureDetector(
      onTap: () => onChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.accent : theme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 