import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/features/pomodoro/models/pomodoro_timer.dart';

class TimerControls extends StatefulWidget {
  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSkip,
  });

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
      builder: (context, theme) => ScaleTransition(
        scale: _scaleAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              theme,
              icon: Icons.refresh_rounded,
              onPressed: () {
                _controller.reverse().then((_) {
                  widget.onReset();
                  _controller.forward();
                });
              },
              size: 32,
              color: theme.textSecondary,
            ),
            const SizedBox(width: 32),
            _buildControlButton(
              theme,
              icon: widget.status == TimerStatus.running
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              onPressed: () {
                _controller.reverse().then((_) {
                  if (widget.status == TimerStatus.running) {
                    widget.onPause();
                  } else {
                    widget.onStart();
                  }
                  _controller.forward();
                });
              },
              size: 48,
              color: theme.accent,
              withGradient: true,
            ),
            const SizedBox(width: 32),
            RotationTransition(
              turns: _rotateAnimation,
              child: _buildControlButton(
                theme,
                icon: Icons.skip_next_rounded,
                onPressed: () {
                  _controller.reverse().then((_) {
                    widget.onSkip();
                    _controller.forward();
                  });
                },
                size: 32,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    AppThemeData theme, {
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    required Color color,
    bool withGradient = false,
  }) {
    if (withGradient) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.accent, theme.accentLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.accent.withOpacity(0.2),
              blurRadius: widget.status == TimerStatus.running ? 15 : 10,
              spreadRadius: widget.status == TimerStatus.running ? 3 : 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  icon,
                  key: ValueKey(icon),
                  color: Colors.white,
                  size: size,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
      splashRadius: 24,
    );
  }
} 