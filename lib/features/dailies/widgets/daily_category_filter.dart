import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/dailies/models/daily_task.dart';

class DailyCategoryFilter extends StatelessWidget {
  final DailyCategory? selectedCategory;
  final Function(DailyCategory?) onCategorySelected;

  const DailyCategoryFilter({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DailyCategory.values.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip(
              label: 'All',
              isSelected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
            );
          }

          final category = DailyCategory.values[index - 1];
          return _buildFilterChip(
            label: category.name,
            isSelected: category == selectedCategory,
            onSelected: (_) => onCategorySelected(category),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
} 