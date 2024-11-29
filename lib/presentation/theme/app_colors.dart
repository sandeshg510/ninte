import 'package:flutter/material.dart';
import 'app_theme_data.dart';

/// Provides theme colors throughout the app using InheritedWidget
/// This allows easy access to current theme colors from any widget
class AppColors extends InheritedWidget {
  /// Current theme data containing all color definitions
  final AppThemeData theme;

  const AppColors({
    super.key,
    required this.theme,
    required super.child,
  });

  /// Get the current theme data from context
  /// Throws assertion error if AppColors is not found in widget tree
  static AppThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppColors>();
    assert(widget != null, 'No AppColors found in context');
    return widget!.theme;
  }

  /// Convenient builder pattern for using theme colors
  /// Usage: AppColors.withTheme((context, theme) => Widget(...))
  static Widget withTheme({
    required Widget Function(BuildContext context, AppThemeData theme) builder,
  }) {
    return Builder(
      builder: (context) => builder(context, of(context)),
    );
  }

  // Static color getters with fallback values
  /// Primary accent color
  static Color get accent => _currentTheme?.accent ?? const Color(0xFF6B8AFE);
  
  /// Lighter variant of accent color
  static Color get accentLight => _currentTheme?.accentLight ?? const Color(0xFF8BA4FF);
  
  /// Secondary accent color
  static Color get accentSecondary => _currentTheme?.accentSecondary ?? const Color(0xFF4D6EFD);
  
  /// Main background color
  static Color get background => _currentTheme?.background ?? const Color(0xFF121212);
  
  /// Surface color for cards
  static Color get surface => _currentTheme?.surface ?? const Color(0xFF1E1E1E);
  
  /// Lighter surface color
  static Color get surfaceLight => _currentTheme?.surfaceLight ?? const Color(0xFF2C2C2C);
  
  /// Primary text color
  static Color get textPrimary => _currentTheme?.textPrimary ?? const Color(0xFFFFFFFF);
  
  /// Secondary text color
  static Color get textSecondary => _currentTheme?.textSecondary ?? const Color(0xFFB3B3B3);
  
  /// Tertiary text color
  static Color get textTertiary => _currentTheme?.textTertiary ?? const Color(0xFF808080);
  
  /// Error color
  static Color get error => _currentTheme?.error ?? const Color(0xFFFF5252);
  
  /// Success color
  static Color get success => _currentTheme?.success ?? const Color(0xFF4CAF50);
  
  /// Warning color
  static Color get warning => const Color(0xFFFFB74D);
  
  // Utility colors
  /// Border color for glass effect
  static Color get glassBorder => textSecondary.withOpacity(0.1);
  
  /// Background color for glass effect
  static Color get glassBackground => surface.withOpacity(0.8);
  
  // Gradients
  /// Warm gradient using accent colors
  static LinearGradient get warmGradient => LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cache of current theme for static access
  static AppThemeData? _currentTheme;
  
  @override
  bool updateShouldNotify(AppColors oldWidget) {
    _currentTheme = theme;
    return theme != oldWidget.theme;
  }
} 