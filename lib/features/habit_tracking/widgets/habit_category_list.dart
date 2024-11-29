import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class HabitCategoryList extends ConsumerWidget {
  const HabitCategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(habitCategoriesProvider);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 24 : 8,
              right: index == categories.length - 1 ? 24 : 0,
            ),
            child: FilterChip(
              label: Text('${category.category.name} (${category.count})'),
              selected: false,
              onSelected: (selected) {
                // TODO: Implement filtering
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent.withOpacity(0.2),
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
} 