import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/widgets/interactive_card.dart';
import 'package:ninte/presentation/utils/animations.dart';
import 'package:ninte/presentation/widgets/section_header.dart';
import 'package:ninte/presentation/widgets/period_selector.dart';
import 'package:ninte/presentation/widgets/circular_progress.dart';
import 'package:ninte/presentation/widgets/stats_card.dart';
import 'package:ninte/presentation/widgets/achievement_card.dart';
import 'package:ninte/presentation/widgets/progress_chart.dart';
import 'package:ninte/presentation/widgets/habit_progress_card.dart';
import 'package:ninte/presentation/widgets/gradient_container.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  TimePeriod _selectedPeriod = TimePeriod.week;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.extraLongDuration,
      vsync: this,
    );

    // Create staggered animations for each section
    _fadeAnimations = List.generate(
      5,
      (index) => AppAnimations.fadeAnimation(
        _animationController,
        delay: index * 0.1,
      ),
    );

    _slideAnimations = List.generate(
      5,
      (index) => AppAnimations.slideAnimation(
        _animationController,
        delay: index * 0.1,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => RefreshIndicator(
        color: theme.accent,
        backgroundColor: theme.surface,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _animationController.reset();
          _animationController.forward();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with Period Selector
            SliverAppBar(
              floating: true,
              backgroundColor: theme.background,
              title: Text(
                'Dashboard',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Center(
                  child: PeriodSelector(
                    selected: _selectedPeriod,
                    onChanged: (period) {
                      setState(() => _selectedPeriod = period);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: theme.textPrimary,
                  ),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),

            // Today's Progress
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimations[0],
                child: SlideTransition(
                  position: _slideAnimations[0],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: InteractiveCard(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accent.withOpacity(0.15),
                              theme.accentLight.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            // Header with improved layout and fixed overflow
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    color: theme.accent,
                                    size: 20,  // Reduced size
                                  ),
                                ),
                                const SizedBox(width: 12),  // Reduced spacing
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Today's Progress",
                                        style: TextStyle(
                                          color: theme.textSecondary,
                                          fontSize: 14,  // Reduced font size
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),  // Reduced spacing
                                      Text(
                                        '6 out of 8 habits',  // Shortened text
                                        style: TextStyle(
                                          color: theme.textPrimary,
                                          fontSize: 12,  // Reduced font size
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),  // Added spacing
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,  // Reduced padding
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '75%',
                                    style: TextStyle(
                                      color: theme.accent,
                                      fontSize: 16,  // Reduced font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Content with improved layout
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left side - Progress Circle
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.surface.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgress(
                                      progress: 0.75,
                                      label: '',
                                      value: '',
                                      size: 100,
                                      strokeWidth: 10,
                                      showCenterContent: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Right side - Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events_rounded,
                                            color: theme.accent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Keep it up!',
                                            style: TextStyle(
                                              color: theme.textPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: _buildMiniStat(
                                              theme,
                                              icon: Icons.access_time_rounded,
                                              value: '2',
                                              label: 'Remaining',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Flexible(
                                            child: _buildMiniStat(
                                              theme,
                                              icon: Icons.local_fire_department_rounded,
                                              value: '5',
                                              label: 'Streak',
                                              valueColor: theme.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Stats Section with Horizontal Scroll
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimations[1],
                child: SlideTransition(
                  position: _slideAnimations[1],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Statistics',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Period selector with better styling
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.surfaceLight.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPeriodButton(
                                    theme,
                                    'Week',
                                    isSelected: true,
                                    onTap: () {
                                      // TODO: Handle period change
                                    },
                                  ),
                                  _buildPeriodButton(
                                    theme,
                                    'Month',
                                    isSelected: false,
                                    onTap: () {
                                      // TODO: Handle period change
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Weekly Streak Card
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: InteractiveCard(
                                onTap: () {
                                  // TODO: Show detailed stats
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: theme.accent.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: theme.accent.withOpacity(0.1),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.local_fire_department_rounded,
                                              color: theme.accent,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Weekly Streak',
                                                  style: TextStyle(
                                                    color: theme.textSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '5',
                                                      style: TextStyle(
                                                        color: theme.textPrimary,
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'days',
                                                      style: TextStyle(
                                                        color: theme.textSecondary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    _buildTrendIndicator(
                                                      theme,
                                                      value: 2,
                                                      isPositive: true,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Weekly Progress Bars
                                      SizedBox(
                                        height: 120,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: List.generate(7, (index) {
                                            final isToday = index == 4;
                                            return _buildDayBar(
                                              theme,
                                              day: ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                                              value: [0.6, 0.8, 0.7, 0.9, 0.75, 0.0, 0.0][index],
                                              isActive: index <= 4,
                                              isToday: isToday,
                                            );
                                          }),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Best Streak Indicator
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.surfaceLight.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: theme.surfaceLight.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.emoji_events_rounded,
                                              color: theme.accent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Best Streak: 7 days',
                                              style: TextStyle(
                                                color: theme.textSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Completion Rate Card
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: InteractiveCard(
                                onTap: () {
                                  // TODO: Show detailed stats
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: theme.success.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: theme.success.withOpacity(0.1),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.trending_up_rounded,
                                              color: theme.success,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Completion Rate',
                                                  style: TextStyle(
                                                    color: theme.textSecondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '85%',
                                                      style: TextStyle(
                                                        color: theme.textPrimary,
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    _buildTrendIndicator(
                                                      theme,
                                                      value: 5,
                                                      isPositive: true,
                                                      useSuccessColor: true,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Line Chart
                                      SizedBox(
                                        height: 120,
                                        child: _buildLineChart(theme),
                                      ),
                                      const SizedBox(height: 16),
                                      // Average Indicator
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.surfaceLight.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: theme.surfaceLight.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_graph_rounded,
                                              color: theme.success,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Weekly Average: 82%',
                                              style: TextStyle(
                                                color: theme.textSecondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Progress Overview Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: _slideAnimations[2],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress Overview',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PeriodSelector(
                              selected: _selectedPeriod,
                              onChanged: (period) {
                                setState(() => _selectedPeriod = period);
                                // TODO: Update chart data based on period
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ProgressChart(
                          title: 'Weekly Progress',
                          data: const [65, 70, 85, 75, 90, 80, 85],
                          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                          maxValue: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Today's Habits Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimations[3],
                child: SlideTransition(
                  position: _slideAnimations[3],
                  child: Column(
                    children: [
                      SectionHeader(
                        title: "Today's Habits",
                        onSeeAll: () {
                          // TODO: Navigate to habits list
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            HabitProgressCard(
                              title: 'Morning Workout',
                              subtitle: '30 minutes of exercise',
                              icon: Icons.fitness_center_rounded,
                              progress: 0.0,
                              isCompleted: true,
                              onTap: () {
                                // TODO: Handle habit tap
                              },
                            ),
                            const SizedBox(height: 16),
                            HabitProgressCard(
                              title: 'Read a Book',
                              subtitle: '15 minutes remaining',
                              icon: Icons.book_rounded,
                              progress: 0.75,
                              onTap: () {
                                // TODO: Handle habit tap
                              },
                            ),
                            const SizedBox(height: 16),
                            HabitProgressCard(
                              title: 'Meditate',
                              subtitle: 'Start 10 min session',
                              icon: Icons.self_improvement_rounded,
                              progress: 0.0,
                              onTap: () {
                                // TODO: Handle habit tap
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Recent Achievements Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimations[4],
                child: SlideTransition(
                  position: _slideAnimations[4],
                  child: Column(
                    children: [
                      SectionHeader(
                        title: 'Recent Achievements',
                        onSeeAll: () {
                          // TODO: Navigate to achievements
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: const [
                            AchievementCard(
                              title: 'Early Bird',
                              description: 'Complete morning routine 7 days in a row',
                              icon: Icons.wb_sunny_rounded,
                              progress: 0.8,
                              isUnlocked: false,
                            ),
                            SizedBox(height: 16),
                            AchievementCard(
                              title: 'Consistency King',
                              description: 'Maintain a 30-day streak',
                              icon: Icons.emoji_events_rounded,
                              progress: 1.0,
                              isUnlocked: true,
                              customColor: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    AppThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.surfaceLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: valueColor ?? theme.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(AppThemeData theme, String text, {required bool isSelected, Function()? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? theme.accent.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? theme.accent : theme.textSecondary,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDayBar(
    AppThemeData theme, {
    required String day,
    required double value,
    required bool isActive,
    bool isToday = false,
  }) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              color: theme.surfaceLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isActive ? 80 * value : 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.accent,
                        theme.accentLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isToday ? theme.accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            day,
            style: TextStyle(
              color: isToday ? theme.accent : theme.textSecondary,
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(
    AppThemeData theme, {
    required int value,
    required bool isPositive,
    bool useSuccessColor = false,
  }) {
    final color = useSuccessColor ? theme.success : theme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isPositive ? '+$value' : '-$value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(AppThemeData theme) {
    // TODO: Implement line chart
    return Container();
  }

  Widget _buildProgressCard() {
    return AppColors.withTheme(
      builder: (context, theme) => GradientContainer(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.accent.withOpacity(0.15),
                theme.accentLight.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.surfaceLight.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: theme.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '6/10 Tasks',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 