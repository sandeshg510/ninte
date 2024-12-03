import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme.dart';

/// Helper class to create styles without const
class AppTextStyles {
  static TextStyle get titleLarge => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get titleMedium => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  );

  // Add more styles as needed
}

/// Helper class to create decorations without const
class AppDecorations {
  static BoxDecoration get glassCard => BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
  );

  // Add more decorations as needed
} 