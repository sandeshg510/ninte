import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/dailies/models/daily_task.dart';

class DailyTaskCard extends StatelessWidget {
  final DailyTask task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const DailyTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main Task Row
                Row(
                  children: [
                    // Left side - Task icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppColors.accent.withOpacity(0.1)
                            : AppColors.textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        color: task.isCompleted 
                            ? AppColors.accent 
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Middle - Task details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: task.isCompleted 
                                  ? AppColors.textSecondary 
                                  : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeOfDay.fromDateTime(task.dueTime).format(context),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Checkbox
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onComplete?.call(),
                      activeColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                // Additional Info (collapsible)
                if (task.description.isNotEmpty || task.priority != DailyPriority.medium) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (task.description.isNotEmpty) ...[
                        Expanded(
                          child: Text(
                            task.description,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _buildPriorityBadge(),
                      const SizedBox(width: 8),
                      _buildCategoryBadge(),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    IconData icon;
    
    switch (task.priority) {
      case DailyPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward_rounded;
        break;
      case DailyPriority.medium:
        color = Colors.orange;
        icon = Icons.remove_rounded;
        break;
      case DailyPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward_rounded;
        break;
      case DailyPriority.critical:
        color = Colors.purple;
        icon = Icons.priority_high_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            task.priority.name,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            color: AppColors.textSecondary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            task.category.name,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (task.category) {
      case DailyCategory.personal:
        return Icons.person_rounded;
      case DailyCategory.work:
        return Icons.work_rounded;
      case DailyCategory.health:
        return Icons.favorite_rounded;
      case DailyCategory.study:
        return Icons.school_rounded;
      case DailyCategory.fitness:
        return Icons.fitness_center_rounded;
      case DailyCategory.shopping:
        return Icons.shopping_bag_rounded;
      case DailyCategory.other:
        return Icons.category_rounded;
    }
  }
} 