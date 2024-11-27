import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class AppStyles {
  // Text Styles
  static TextStyle get headingLarge => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headingMedium => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get titleLarge => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
  );

  static TextStyle get bodyMedium => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  // Decorations
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
  );

  // Input Decoration Theme
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.glassBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.glassBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.accent),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    labelStyle: TextStyle(color: AppColors.textSecondary),
  );
} 