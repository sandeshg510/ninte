import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeData {
  final String name;
  final String description;
  final List<ThemeTag> tags;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color accent;
  final Color accentLight;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color error;
  final Color success;
  final Color warning;

  const AppThemeData({
    required this.name,
    required this.description,
    required this.tags,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.accent,
    required this.accentLight,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.error,
    required this.success,
    required this.warning,
  });

  Color get glassBorder => surfaceLight.withOpacity(0.2);
  Color get glassBackground => surface.withOpacity(0.8);

  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        primaryColor: accent,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          tertiary: accentSecondary,
          background: background,
          surface: surface,
          error: error,
          onPrimary: textPrimary,
          onSecondary: textPrimary,
          onSurface: textPrimary,
          onBackground: textPrimary,
          onError: textPrimary,
        ),
      );
} 