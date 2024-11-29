import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/gradient_container.dart';
import 'package:ninte/presentation/pages/home/animations/tab_animations.dart';
import 'package:ninte/features/dailies/models/daily_task.dart';
import 'package:ninte/features/dailies/providers/daily_provider.dart';
import 'package:ninte/features/dailies/widgets/daily_task_card.dart';
import 'package:ninte/features/dailies/widgets/daily_category_filter.dart';
import 'package:ninte/features/dailies/widgets/create_daily_modal.dart';
import 'package:ninte/features/dailies/providers/daily_state.dart';
import 'dart:developer' as dev;

class DailiesTab extends ConsumerStatefulWidget {
  const DailiesTab({super.key});

  @override
  ConsumerState<DailiesTab> createState() => _DailiesTabState();
}

class _DailiesTabState extends ConsumerState<DailiesTab> {
  DailyCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final dailyState = ref.watch(dailyProvider);
    final todayTasks = dailyState.todayTasks;
    final completedTasks = dailyState.completedTasks;
    final progress = ref.watch(dailyProgressProvider);
    final isLoading = ref.watch(dailyLoadingProvider);
    final error = ref.watch(dailyErrorProvider);
    final sortedTasks = ref.watch(sortedDailiesProvider);

    dev.log('DailiesTab - Total tasks today: ${todayTasks.length}');
    dev.log('DailiesTab - Completed tasks: ${completedTasks.length}');
    
    if (error != null) {
      dev.log('DailiesTab Error: $error');
    }

    return AnimatedTabContent(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      color: AppColors.textSecondary,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    Text(
                      'Daily Tasks',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.calendar_today_rounded),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        // TODO: Implement calendar view
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort_rounded),
                      color: AppColors.textSecondary,
                      onPressed: _showSortOptions,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Fixed Progress Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildDailyProgress(
                  todayTasks.length,
                  completedTasks.length,
                  progress
                ),
              ),

              // Fixed Category Filter
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: DailyCategoryFilter(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
              ),

              // Scrollable Tasks List
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTasksList(sortedTasks),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateDailyModal,
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyProgress(int totalTasks, int completedCount, double progress) {
    return GradientContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount/$totalTasks Tasks',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<DailyTask> tasks) {
    final filteredTasks = _selectedCategory != null
        ? tasks.where((task) => task.category == _selectedCategory).toList()
        : tasks;

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showCreateDailyModal,
              child: const Text('Create your first task'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return DailyTaskCard(
              task: task,
              onTap: () => _showEditDailyModal(task),
              onComplete: () => _toggleTaskCompletion(task),
            );
          },
        ),
        // Add some bottom padding for FAB
        const SizedBox(height: 80),
      ],
    );
  }

  void _showCreateDailyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateDailyModal(),
    );
  }

  void _showEditDailyModal(DailyTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateDailyModal(task: task),
    );
  }

  void _toggleTaskCompletion(DailyTask task) {
    ref.read(dailyProvider.notifier).toggleDailyComplete(task.id, !task.isCompleted);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: DailySortOption.values.map((option) {
          return ListTile(
            leading: Icon(
              _getSortIcon(option),
              color: AppColors.textSecondary,
            ),
            title: Text(
              _getSortLabel(option),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              ref.read(dailySortOptionProvider.notifier).state = option;
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  IconData _getSortIcon(DailySortOption option) {
    switch (option) {
      case DailySortOption.dueTime:
        return Icons.access_time_rounded;
      case DailySortOption.priority:
        return Icons.priority_high_rounded;
      case DailySortOption.alphabetical:
        return Icons.sort_by_alpha_rounded;
      case DailySortOption.category:
        return Icons.category_rounded;
      default:
        return Icons.sort_rounded;
    }
  }

  String _getSortLabel(DailySortOption option) {
    switch (option) {
      case DailySortOption.dueTime:
        return 'Sort by Due Time';
      case DailySortOption.priority:
        return 'Sort by Priority';
      case DailySortOption.alphabetical:
        return 'Sort Alphabetically';
      case DailySortOption.category:
        return 'Sort by Category';
      default:
        return 'Sort';
    }
  }
} 