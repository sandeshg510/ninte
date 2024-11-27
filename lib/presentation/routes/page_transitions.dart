import 'package:flutter/material.dart';

class ThemeTransitionPage extends PageRouteBuilder {
  final Widget page;

  ThemeTransitionPage({
    required this.page,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class ThemeChangeAnimation extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final bool isAnimating;

  const ThemeChangeAnimation({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isAnimating ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          color: backgroundColor.withOpacity(value * 0.3),
          child: Opacity(
            opacity: 1.0 - (value * 0.2),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
} 