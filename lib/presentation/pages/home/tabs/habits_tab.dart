import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/presentation/pages/home/animations/tab_animations.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_streak_calendar.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_stats_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_progress_summary.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_category_list.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_completion_animation.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_detail_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_achievement_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_milestone_card.dart';
import 'package:ninte/features/habit_tracking/pages/archived_habits_page.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_archive_animation.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_completion_celebration.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_insights_card.dart';
import 'package:ninte/features/habit_tracking/pages/habit_insights_page.dart';
import 'package:ninte/features/habit_tracking/pages/habit_detail_page.dart';

class HabitFrequencyTab extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final HabitFrequency frequency;

  const HabitFrequencyTab({
    super.key,
    required this.habits,
    required this.frequency,
  });

  @override
  ConsumerState<HabitFrequencyTab> createState() => _HabitFrequencyTabState();
}

class _HabitFrequencyTabState extends ConsumerState<HabitFrequencyTab> {
  final Map<String, bool> _animatingHabits = {};
  final Map<String, bool> _completingHabits = {};

  @override
  Widget build(BuildContext context) {
    final filteredHabits = widget.habits.where((h) => 
      !h.isArchived && h.frequency == widget.frequency
    ).toList();

    if (filteredHabits.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.frequency.name} habits yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) => _buildHabitCard(
        context,
        filteredHabits[index],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final stats = ref.watch(habitStatsProvider(habit.id));
    final isDue = habit.isDueToday;
    final isAnimating = _animatingHabits[habit.id] ?? false;
    final isCompleting = _completingHabits[habit.id] ?? false;

    return Stack(
      children: [
        HabitArchiveAnimation(
          key: ValueKey('archive_${habit.id}'),
          isArchiving: true,
          shouldAnimate: isAnimating,
          onComplete: () {
            if (mounted) {
              setState(() {
                _animatingHabits.remove(habit.id);
              });
            }
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitDetailPage(habit: habit),
                ),
              );
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
                            const SizedBox(height: 4),
                            Text(
                              '${habit.frequency.name} • ${habit.reminderTime != null ? TimeOfDay.fromDateTime(habit.reminderTime!).format(context) : 'No reminder'}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDue)
                        IconButton(
                          icon: Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.accent,
                          ),
                          onPressed: () => _completeHabit(habit.id),
                        ),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.textSecondary,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Edit'),
                            onTap: () {
                              // TODO: Show edit modal
                            },
                          ),
                          PopupMenuItem(
                            child: Text('Archive'),
                            onTap: () async {
                              await Future.delayed(const Duration(milliseconds: 200));
                              if (mounted) {
                                setState(() {
                                  _animatingHabits[habit.id] = true;
                                });
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (mounted) {
                                  await ref.read(habitProvider.notifier).archiveHabit(habit.id);
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
                  if (stats != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Streak: ${stats['currentStreak']} days',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildCompletionStreak(habit),
                ],
              ),
            ),
          ),
        ),
        if (isCompleting)
          Positioned.fill(
            child: HabitCompletionAnimation(
              onAnimationComplete: () {
                if (mounted) {
                  setState(() {
                    _completingHabits.remove(habit.id);
                  });
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCompletionStreak(Habit habit) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    switch (habit.frequency) {
      case HabitFrequency.daily:
        // Show daily streak for the current week
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final weekDates = List.generate(7, (index) {
          return monday.add(Duration(days: index));
        });

        return Column(
          children: [
            Row(
              children: weekDates.map((date) {
                final isCompleted = habit.completedDates.any((d) =>
                    d.year == date.year &&
                    d.month == date.month &&
                    d.day == date.day);
                final isToday = date.year == now.year && 
                               date.month == now.month && 
                               date.day == now.day;

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        weekDays[date.weekday - 1],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? AppColors.accent 
                              : isToday 
                                  ? AppColors.textTertiary.withOpacity(0.5)
                                  : AppColors.textTertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case HabitFrequency.weekly:
        // Show past weeks if there's a streak, otherwise show future weeks
        final weeks = List.generate(7, (index) {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          
          // Calculate week date based on streak
          final weekDate = habit.currentStreak > 0
              ? weekStart.subtract(Duration(days: (6 - index) * 7)) // Past weeks
              : weekStart.add(Duration(days: index * 7)); // Future weeks
          
          final isCompleted = habit.completedDates.any((d) =>
              d.isAfter(weekDate.subtract(const Duration(days: 1))) &&
              d.isBefore(weekDate.add(const Duration(days: 7))));
          final isCurrentWeek = _isSameWeek(weekDate, now);

          // Calculate week number relative to current week
          final weekNumber = habit.currentStreak > 0
              ? -(5 - index) // Count backwards from -5 to 0 for past weeks
              : index + 1;   // Count forwards from 1 to 6 for future weeks

          return Expanded(
            child: Column(
              children: [
                Text(
                  'W${weekNumber.abs()}', // Use absolute value for display
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.accent 
                        : isCurrentWeek
                            ? AppColors.textTertiary.withOpacity(0.5)
                            : AppColors.textTertiary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        });

        // Return weeks in correct order (left to right)
        return Row(children: habit.currentStreak > 0 
            ? weeks // Past weeks are already in correct order
            : weeks // Future weeks are already in correct order
        );

      case HabitFrequency.monthly:
        // Show past months if there's a streak, otherwise show future months
        final months = List.generate(6, (index) {
          final now = DateTime.now();
          final monthDate = habit.currentStreak > 0
              ? DateTime(now.year, now.month - (5 - index)) // Past months
              : DateTime(now.year, now.month + index); // Future months
          
          final isCompleted = habit.completedDates.any((d) =>
              d.year == monthDate.year && d.month == monthDate.month);
          final isCurrentMonth = monthDate.year == now.year && 
                                monthDate.month == now.month;

          return Expanded(
            child: Column(
              children: [
                Text(
                  '${monthDate.month}/${monthDate.year.toString().substring(2)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppColors.accent 
                        : isCurrentMonth
                            ? AppColors.textTertiary.withOpacity(0.5)
                            : AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        });

        return Row(children: months);

      case HabitFrequency.custom:
        // For custom frequency, show last 7 completions
        return _buildCustomFrequencyStreak(habit);
    }
  }

  Widget _buildCustomFrequencyStreak(Habit habit) {
    final completions = habit.completedDates.take(7).toList();
    return Row(
      children: List.generate(7, (index) {
        final hasCompletion = index < completions.length;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: hasCompletion 
                  ? AppColors.accent 
                  : AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
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
    }
  }

  int _calculateNextMilestone(int currentStreak) {
    if (currentStreak < 7) return 7 - currentStreak;
    if (currentStreak < 14) return 14 - currentStreak;
    if (currentStreak < 30) return 30 - currentStreak;
    if (currentStreak < 60) return 60 - currentStreak;
    if (currentStreak < 90) return 90 - currentStreak;
    return 100 - (currentStreak % 100);
  }

  String _getNextMilestoneText(int currentStreak) {
    if (currentStreak < 7) return '7 Day Streak';
    if (currentStreak < 14) return '14 Day Streak';
    if (currentStreak < 30) return '30 Day Streak';
    if (currentStreak < 60) return '60 Day Streak';
    if (currentStreak < 90) return '90 Day Streak';
    final nextCentury = ((currentStreak ~/ 100) + 1) * 100;
    return '$nextCentury Day Streak';
  }

  void _completeHabit(String habitId) async {
    setState(() {
      _completingHabits[habitId] = true;
    });
    
    // Wait for animation to start
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mark habit as complete
    await ref.read(habitProvider.notifier).markHabitComplete(habitId);
    
    // Animation will be dismissed via onAnimationComplete callback
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    final monday2 = date2.subtract(Duration(days: date2.weekday - 1));
    return monday1.year == monday2.year && 
           monday1.month == monday2.month && 
           monday1.day == monday2.day;
  }
}

class HabitsTab extends ConsumerStatefulWidget {
  const HabitsTab({super.key});

  @override
  ConsumerState<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends ConsumerState<HabitsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider).habits;
    final isLoading = ref.watch(habitLoadingProvider);
    final error = ref.watch(habitErrorProvider);

    return AnimatedTabContent(
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: AppColors.background,
              title: Text(
                'My Habits',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.insights_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HabitInsightsPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArchivedHabitsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: const HabitProgressSummary(),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
              ],
            ),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                  ? Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(color: AppColors.error),
                      ),
                    )
                  : habits.isEmpty
                    ? const Center(
                        child: Text(
                          'No habits yet. Create one!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          HabitFrequencyTab(
                            habits: habits,
                            frequency: HabitFrequency.daily,
                          ),
                          HabitFrequencyTab(
                            habits: habits,
                            frequency: HabitFrequency.weekly,
                          ),
                          HabitFrequencyTab(
                            habits: habits,
                            frequency: HabitFrequency.monthly,
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