import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_archive_animation.dart';

class ArchivedHabitsPage extends ConsumerStatefulWidget {
  const ArchivedHabitsPage({super.key});

  @override
  ConsumerState<ArchivedHabitsPage> createState() => _ArchivedHabitsPageState();
}

class _ArchivedHabitsPageState extends ConsumerState<ArchivedHabitsPage> {
  Map<String, bool> _animatingHabits = {};

  @override
  Widget build(BuildContext context) {
    final archivedHabits = ref.watch(archivedHabitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Archived Habits',
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
      body: archivedHabits.isEmpty
          ? Center(
              child: Text(
                'No archived habits',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = archivedHabits[index];
                final isAnimating = _animatingHabits[habit.id] ?? false;

                return HabitArchiveAnimation(
                  key: ValueKey(habit.id),
                  isArchiving: false,
                  shouldAnimate: isAnimating,
                  onComplete: () {
                    if (mounted) {
                      setState(() {
                        _animatingHabits.remove(habit.id);
                      });
                    }
                  },
                  child: AppCard(
                    margin: const EdgeInsets.only(bottom: 16),
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
                                _getIconForCategory(habit.category),
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (habit.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      habit.description,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.textSecondary,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text('Unarchive'),
                                  onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));
                                    if (mounted) {
                                      setState(() {
                                        _animatingHabits[habit.id] = true;
                                      });
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      if (mounted) {
                                        await ref.read(habitProvider.notifier).unarchiveHabit(habit.id);
                                      }
                                    }
                                  },
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                  onTap: () {
                                    ref.read(habitProvider.notifier).deleteHabit(habit.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.favorite_rounded;
      case HabitCategory.productivity:
        return Icons.lightbulb_rounded;
      case HabitCategory.learning:
        return Icons.school_rounded;
      case HabitCategory.fitness:
        return Icons.fitness_center_rounded;
      case HabitCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case HabitCategory.social:
        return Icons.people_rounded;
      case HabitCategory.other:
        return Icons.category_rounded;
      default:
        return Icons.category_rounded;
    }
  }
} 