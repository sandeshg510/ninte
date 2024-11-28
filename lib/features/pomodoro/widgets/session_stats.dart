import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class SessionStats extends StatefulWidget {
  final int completedSessions;
  final int totalMinutes;
  final int currentStreak;
  final int bestStreak;

  const SessionStats({
    super.key,
    required this.completedSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  State<SessionStats> createState() => _SessionStatsState();
}

class _SessionStatsState extends State<SessionStats> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.surfaceLight.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      theme,
                      icon: Icons.check_circle_outline_rounded,
                      value: widget.completedSessions.toString(),
                      label: 'Sessions',
                      delay: 0,
                    ),
                    VerticalDivider(
                      color: theme.surfaceLight,
                      thickness: 1,
                      width: 1,
                    ),
                    _buildStat(
                      theme,
                      icon: Icons.timer_outlined,
                      value: '${widget.totalMinutes}',
                      label: 'Minutes',
                      delay: 0.2,
                    ),
                    VerticalDivider(
                      color: theme.surfaceLight,
                      thickness: 1,
                      width: 1,
                    ),
                    _buildStat(
                      theme,
                      icon: Icons.local_fire_department_rounded,
                      value: '${widget.currentStreak}',
                      label: 'Streak',
                      subtitle: 'Best: ${widget.bestStreak}',
                      delay: 0.4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    AppThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    String? subtitle,
    required double delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.accent),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 