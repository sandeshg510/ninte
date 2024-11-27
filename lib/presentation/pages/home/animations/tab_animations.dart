import 'package:flutter/material.dart';

class TabAnimationController {
  final AnimationController controller;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;

  TabAnimationController({required this.controller}) {
    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));
  }

  void dispose() {
    controller.dispose();
  }
}

class AnimatedTabContent extends StatefulWidget {
  final Widget child;

  const AnimatedTabContent({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedTabContent> createState() => _AnimatedTabContentState();
}

class _AnimatedTabContentState extends State<AnimatedTabContent>
    with SingleTickerProviderStateMixin {
  late TabAnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = TabAnimationController(
      controller: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animationController.controller.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController.fadeAnimation,
      child: SlideTransition(
        position: _animationController.slideAnimation,
        child: widget.child,
      ),
    );
  }
} 