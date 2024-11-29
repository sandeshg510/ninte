import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';
import 'package:ninte/presentation/widgets/app_card.dart';
import 'package:ninte/features/habit_tracking/widgets/habit_completion_animation.dart';

class HabitDetailPage extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailPage({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(habitStatsProvider(widget.habit.id));
    final currentStreak = stats?['currentStreak'] as int? ?? 0;
    final bestStreak = stats?['bestStreak'] as int? ?? 0;
    final completionsThisMonth = stats?['thisMonth'] as int? ?? 0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              // Top Background Gradient
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accent.withOpacity(0.2),
                      AppColors.background.withOpacity(0),
                    ],
                  ),
                ),
              ),
              
              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Container(
                      margin: const EdgeInsets.only(top: 100, bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Badge and Actions Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(widget.habit.category),
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.habit.category.name,
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Show edit modal
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () => _showDeleteConfirmation(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Title and Description
                          Text(
                            widget.habit.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          if (widget.habit.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.habit.description,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          
                          // Frequency and Reminder Info
                          Row(
                            children: [
                              // Frequency
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.accent.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.habit.frequency.name,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Reminder (if set)
                              if (widget.habit.reminderTime != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.accent.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.notifications_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        TimeOfDay.fromDateTime(widget.habit.reminderTime!).format(context),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stats Section with improved layout
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Current Streak',
                              '$currentStreak days',
                              Icons.local_fire_department_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Best Streak',
                              '$bestStreak days',
                              Icons.emoji_events_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details Section with better grouping
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 16),
                            child: Text(
                              'Details',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildDetailRow(
                            'Frequency',
                            widget.habit.frequency.name,
                            Icons.repeat_rounded,
                          ),
                          if (widget.habit.reminderTime != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Reminder',
                              TimeOfDay.fromDateTime(widget.habit.reminderTime!).format(context),
                              Icons.notifications_rounded,
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Completions',
                            '$completionsThisMonth this month',
                            Icons.check_circle_rounded,
                          ),
                        ],
                      ),
                    ),

                    // Calendar Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 16),
                            child: Text(
                              'Completion History',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _buildCompletionCalendar(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: widget.habit.isDueToday
              ? FloatingActionButton.extended(
                  onPressed: _completeHabit,
                  backgroundColor: AppColors.accent,
                  icon: Icon(Icons.check_rounded, color: AppColors.surface),
                  label: Text(
                    'Complete',
                    style: TextStyle(color: AppColors.surface),
                  ),
                )
              : null,
        ),
        
        // Add completion animation layer
        if (_isCompleting)
          Positioned.fill(
            child: HabitCompletionAnimation(
              onAnimationComplete: () {
                if (mounted) {
                  setState(() => _isCompleting = false);
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(widget.habit.category),
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          Text(
            widget.habit.category.name,
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCalendar() {
    // TODO: Implement calendar view
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Calendar Coming Soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(HabitCategory category) {
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Habit',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this habit?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(widget.habit.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail page
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _completeHabit() async {
    setState(() => _isCompleting = true);
    
    // Wait for animation to start
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mark habit as complete
    await ref.read(habitProvider.notifier).markHabitComplete(widget.habit.id);
    
    // Animation will be dismissed via onAnimationComplete callback
  }
} 