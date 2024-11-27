import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glassBackground.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Preset glass containers for common use cases
class PrimaryGlassContainer extends GlassContainer {
  PrimaryGlassContainer({
    super.key,
    required super.child,
    super.padding = const EdgeInsets.all(16),
    super.margin,
    super.borderRadius,
  }) : super(
          opacity: 0.7,
        );
}

class AccentGlassContainer extends GlassContainer {
  AccentGlassContainer({
    super.key,
    required super.child,
    super.padding = const EdgeInsets.all(16),
    super.margin,
    super.borderRadius,
  }) : super(
          opacity: 0.15,
          borderColor: AppColors.accent.withOpacity(0.3),
        );
} 