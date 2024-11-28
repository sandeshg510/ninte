import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.accent.withOpacity(0.15),
              theme.accentLight.withOpacity(0.05),
            ],
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          border: Border.all(
            color: theme.surfaceLight.withOpacity(0.1),
          ),
        ),
        child: child,
      ),
    );
  }
} 