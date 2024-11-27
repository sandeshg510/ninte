import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/utils/animations.dart';

class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableScale;
  final bool enableHover;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.enableScale = true,
    this.enableHover = true,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.defaultDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScale) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScale) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableScale) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = widget.enableScale
                  ? AppAnimations.cardScale(_controller).value
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: AppAnimations.defaultDuration,
                  curve: AppAnimations.defaultCurve,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? theme.surface,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.borderColor ??
                          theme.surfaceLight.withOpacity(_isHovered ? 0.2 : 0.1),
                      width: 1.5,
                    ),
                    boxShadow: widget.boxShadow ??
                        [
                          BoxShadow(
                            color: theme.accent.withOpacity(
                              _isHovered ? 0.1 : 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                  ),
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
} 