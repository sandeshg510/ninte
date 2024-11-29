import 'package:flutter/material.dart';

class HabitArchiveAnimation extends StatefulWidget {
  final Widget child;
  final bool isArchiving;
  final VoidCallback onComplete;
  final bool shouldAnimate;

  const HabitArchiveAnimation({
    super.key,
    required this.child,
    required this.isArchiving,
    required this.onComplete,
    this.shouldAnimate = false,
  });

  @override
  State<HabitArchiveAnimation> createState() => _HabitArchiveAnimationState();
}

class _HabitArchiveAnimationState extends State<HabitArchiveAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.isArchiving ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void didUpdateWidget(HabitArchiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
} 