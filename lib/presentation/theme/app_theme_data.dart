import 'package:flutter/material.dart';

/// Defines the complete theme data structure for the app
/// Contains all visual properties like colors, text styles, and theme metadata
class AppThemeData {
  /// Display name of the theme shown in theme selector
  final String name;

  /// Description of the theme shown in theme selector
  final String description;

  /// List of tags to categorize the theme (e.g., dark, light, minimal)
  final List<ThemeTag> tags;
  
  // Core Colors
  /// Primary accent color used for main actions and highlights
  final Color accent;

  /// Lighter variant of accent color for gradients and hover states
  final Color accentLight;

  /// Secondary accent color for complementary actions
  final Color accentSecondary;

  /// Main background color of the app
  final Color background;

  /// Surface color for cards and elevated components
  final Color surface;

  /// Lighter surface color for subtle differentiation
  final Color surfaceLight;

  // Text Colors
  /// Primary text color for headings and important text
  final Color textPrimary;

  /// Secondary text color for subtitles and less important text
  final Color textSecondary;

  /// Tertiary text color for disabled states and hints
  final Color textTertiary;

  // Semantic Colors
  /// Color used for error states and destructive actions
  final Color error;

  /// Color used for success states and confirmations
  final Color success;

  // Add glassBorder getter
  Color get glassBorder => textSecondary.withOpacity(0.1);

  const AppThemeData({
    required this.name,
    required this.description,
    required this.tags,
    required this.accent,
    required this.accentLight,
    required this.accentSecondary,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.error,
    required this.success,
  });

  /// Converts our custom theme data to Flutter's ThemeData
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    primaryColor: accent,
    scaffoldBackgroundColor: background,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      primary: accent,
      secondary: accentSecondary,
      background: background,
      surface: surface,
      error: error,
      brightness: tags.contains(ThemeTag.dark) ? Brightness.dark : Brightness.light,
    ),
    
    // Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Navigation Rail Theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(color: accent),
      unselectedLabelTextStyle: TextStyle(color: textSecondary),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textPrimary),
      displayMedium: TextStyle(color: textPrimary),
      displaySmall: TextStyle(color: textPrimary),
      headlineLarge: TextStyle(color: textPrimary),
      headlineMedium: TextStyle(color: textPrimary),
      headlineSmall: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary),
      titleMedium: TextStyle(color: textPrimary),
      titleSmall: TextStyle(color: textPrimary),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textTertiary),
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: textPrimary,
      size: 24,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent),
      ),
      labelStyle: TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textTertiary),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: surfaceLight,
      thickness: 1,
      space: 1,
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent;
        }
        return surfaceLight;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent.withOpacity(0.5);
        }
        return surfaceLight.withOpacity(0.5);
      }),
    ),
  );

  /// Linearly interpolate between two themes for smooth transitions
  AppThemeData lerp(AppThemeData other, double t) {
    return AppThemeData(
      name: t < 0.5 ? name : other.name,
      description: t < 0.5 ? description : other.description,
      tags: t < 0.5 ? tags : other.tags,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Tags used to categorize themes for filtering and organization
enum ThemeTag {
  light,   // Light mode themes
  dark,    // Dark mode themes
  minimal, // Clean, minimal designs
  vibrant, // Bright, colorful themes
  nature,  // Nature-inspired colors
  ocean,   // Ocean and water themes
  sunset,  // Warm, sunset colors
  modern   // Modern, trendy designs
} 