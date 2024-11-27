import 'package:flutter/material.dart';
import 'package:ninte/presentation/pages/home/tabs/dashboard_tab.dart';
import 'package:ninte/presentation/pages/home/tabs/habits_tab.dart';
import 'package:ninte/presentation/pages/home/tabs/stats_tab.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/pages/home/modals/create_habit_modal.dart';
import 'package:ninte/presentation/pages/home/tabs/dailies_tab.dart';
import 'package:ninte/presentation/pages/home/modals/create_daily_modal.dart';
import 'package:ninte/presentation/widgets/glass_container.dart';
import 'package:ninte/presentation/widgets/animated_nav_bar.dart';
import 'package:ninte/presentation/pages/settings/settings_page.dart';
import 'package:ninte/presentation/pages/settings/theme_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const DailiesTab(),
    const HabitsTab(),
    const StatsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        physics: const CustomTabBarScrollPhysics(),
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildProfileSection(),
          const SizedBox(height: 16),
          Divider(color: AppColors.glassBorder),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.palette_rounded,
                    title: 'Theme',
                    subtitle: 'Customize app appearance',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementsSection(),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.glassBorder),
          _buildDrawerItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'FAQ and contact',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'See you soon!',
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            isDestructive: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accentLight,
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              child: Text(
                'JD',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.local_fire_department_rounded, '12', 'Habits'),
              Container(
                height: 24,
                width: 1,
                color: AppColors.glassBorder,
              ),
              _buildStatItem(Icons.calendar_today_rounded, '45', 'Days'),
              Container(
                height: 24,
                width: 1,
                color: AppColors.glassBorder,
              ),
              _buildStatItem(Icons.trending_up_rounded, '85%', 'Success'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAchievementItem(
            icon: Icons.emoji_events_rounded,
            title: 'Early Bird',
            subtitle: 'Complete morning routine 7 days in a row',
            progress: 0.7,
          ),
          const SizedBox(height: 8),
          _buildAchievementItem(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak Master',
            subtitle: 'Maintain a 30-day streak',
            progress: 0.45,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        minLeadingWidth: 20,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedNavBar(
      selectedIndex: _currentIndex,
      onItemSelected: (index) {
        _tabController.animateTo(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      items: const [
        NavBarItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
        ),
        NavBarItem(
          icon: Icons.today_rounded,
          label: 'Dailies',
        ),
        NavBarItem(
          icon: Icons.repeat_rounded,
          label: 'Habits',
        ),
        NavBarItem(
          icon: Icons.bar_chart_rounded,
          label: 'Stats',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: (_currentIndex == 1 || _currentIndex == 2) ? 1.0 : 0.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: (_currentIndex == 1 || _currentIndex == 2) ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _currentIndex == 1
                  ? const CreateDailyModal()
                  : const CreateHabitModal(),
            );
          },
          backgroundColor: AppColors.accent,
          child: Icon(
            Icons.add_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class CustomTabBarScrollPhysics extends ScrollPhysics {
  const CustomTabBarScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomTabBarScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
} 