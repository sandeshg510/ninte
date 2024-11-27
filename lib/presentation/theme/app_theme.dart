import 'package:flutter/material.dart';
import 'app_theme_data.dart';

/// Available theme types in the app
/// Each type corresponds to a unique theme configuration
enum ThemeType {
  darkMinimal,   // Clean dark theme
  darkOcean,     // Ocean-inspired dark theme
  darkSunset,    // Warm sunset dark theme
  lightMinimal,  // Clean light theme
  lightNature,   // Nature-inspired light theme
  lightOcean,    // Ocean-inspired light theme
}

/// Central theme configuration class
/// Contains all available themes and their definitions
class AppTheme {
  /// Map of all available themes
  /// Key: ThemeType enum
  /// Value: Corresponding AppThemeData configuration
  static final Map<ThemeType, AppThemeData> themes = {
    ThemeType.darkMinimal: AppThemeData(
      name: 'Dark Minimal',
      description: 'Clean and minimal dark theme',
      tags: [ThemeTag.dark, ThemeTag.minimal],
      accent: const Color(0xFF6B8AFE),
      accentLight: const Color(0xFF8BA4FF),
      accentSecondary: const Color(0xFF4D6EFD),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      surfaceLight: const Color(0xFF2C2C2C),
      textPrimary: const Color(0xFFFFFFFF),
      textSecondary: const Color(0xFFB3B3B3),
      textTertiary: const Color(0xFF808080),
      error: const Color(0xFFFF5252),
      success: const Color(0xFF4CAF50),
    ),
    
    ThemeType.darkOcean: AppThemeData(
      name: 'Dark Ocean',
      description: 'Deep blue dark theme',
      tags: [ThemeTag.dark, ThemeTag.ocean],
      accent: const Color(0xFF64B5F6),
      accentLight: const Color(0xFF90CAF9),
      accentSecondary: const Color(0xFF42A5F5),
      background: const Color(0xFF0A1929),
      surface: const Color(0xFF132F4C),
      surfaceLight: const Color(0xFF173A5E),
      textPrimary: const Color(0xFFFFFFFF),
      textSecondary: const Color(0xFFB3B3B3),
      textTertiary: const Color(0xFF808080),
      error: const Color(0xFFFF5252),
      success: const Color(0xFF4CAF50),
    ),

    ThemeType.darkSunset: AppThemeData(
      name: 'Dark Sunset',
      description: 'Warm sunset-inspired dark theme',
      tags: [ThemeTag.dark, ThemeTag.sunset],
      accent: const Color(0xFFFF6B6B),
      accentLight: const Color(0xFFFF8E8E),
      accentSecondary: const Color(0xFFFF4757),
      background: const Color(0xFF1A1A1A),
      surface: const Color(0xFF242424),
      surfaceLight: const Color(0xFF2E2E2E),
      textPrimary: const Color(0xFFFFFFFF),
      textSecondary: const Color(0xFFB3B3B3),
      textTertiary: const Color(0xFF808080),
      error: const Color(0xFFFF5252),
      success: const Color(0xFF4CAF50),
    ),

    ThemeType.lightMinimal: AppThemeData(
      name: 'Light Minimal',
      description: 'Clean and minimal light theme',
      tags: [ThemeTag.light, ThemeTag.minimal],
      accent: const Color(0xFF6B8AFE),
      accentLight: const Color(0xFF8BA4FF),
      accentSecondary: const Color(0xFF4D6EFD),
      background: const Color(0xFFF5F5F5),
      surface: const Color(0xFFFFFFFF),
      surfaceLight: const Color(0xFFF0F0F0),
      textPrimary: const Color(0xFF1A1A1A),
      textSecondary: const Color(0xFF757575),
      textTertiary: const Color(0xFFBDBDBD),
      error: const Color(0xFFE53935),
      success: const Color(0xFF43A047),
    ),

    ThemeType.lightNature: AppThemeData(
      name: 'Light Nature',
      description: 'Nature-inspired light theme',
      tags: [ThemeTag.light, ThemeTag.nature],
      accent: const Color(0xFF66BB6A),
      accentLight: const Color(0xFF81C784),
      accentSecondary: const Color(0xFF4CAF50),
      background: const Color(0xFFF9FBF9),
      surface: const Color(0xFFFFFFFF),
      surfaceLight: const Color(0xFFF1F8F1),
      textPrimary: const Color(0xFF2E3B2E),
      textSecondary: const Color(0xFF5C715C),
      textTertiary: const Color(0xFFADBDAD),
      error: const Color(0xFFE53935),
      success: const Color(0xFF43A047),
    ),

    ThemeType.lightOcean: AppThemeData(
      name: 'Light Ocean',
      description: 'Ocean-inspired light theme',
      tags: [ThemeTag.light, ThemeTag.ocean],
      accent: const Color(0xFF039BE5),
      accentLight: const Color(0xFF29B6F6),
      accentSecondary: const Color(0xFF0288D1),
      background: const Color(0xFFF5F9FC),
      surface: const Color(0xFFFFFFFF),
      surfaceLight: const Color(0xFFEDF3F7),
      textPrimary: const Color(0xFF1A2C38),
      textSecondary: const Color(0xFF546E7A),
      textTertiary: const Color(0xFFB0BEC5),
      error: const Color(0xFFE53935),
      success: const Color(0xFF43A047),
    ),

    // Add more themes...
  };
} 