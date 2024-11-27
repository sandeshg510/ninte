import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_theme_data.dart';

class AppColors {
  static AppThemeData _currentTheme = AppTheme.defaultTheme;
  static final _notifier = ValueNotifier<int>(0);

  static void setCurrentTheme(AppThemeData theme) {
    _currentTheme = theme;
    _notifier.value++;
  }

  // Add this method for immediate updates
  static Widget withTheme({
    required Widget Function(BuildContext context, AppThemeData theme) builder,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: _notifier,
      builder: (context, _, __) => builder(context, _currentTheme),
    );
  }

  // Base colors
  static Color get background => _currentTheme.background;
  static Color get surface => _currentTheme.surface;
  static Color get surfaceLight => _currentTheme.surfaceLight;
  
  // Text colors
  static Color get textPrimary => _currentTheme.textPrimary;
  static Color get textSecondary => _currentTheme.textSecondary;
  static Color get textTertiary => _currentTheme.textTertiary;
  
  // Accent colors
  static Color get accent => _currentTheme.accent;
  static Color get accentLight => _currentTheme.accentLight;
  static Color get accentSecondary => _currentTheme.accentSecondary;
  
  // Status colors
  static Color get error => _currentTheme.error;
  static Color get success => _currentTheme.success;
  static Color get warning => _currentTheme.warning;
  
  // Effects
  static Color get glassBackground => surface.withOpacity(0.8);
  static Color get glassBorder => surfaceLight.withOpacity(0.2);
  
  static LinearGradient get warmGradient => LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
} 