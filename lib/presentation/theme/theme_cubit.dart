import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

/// Represents the current state of theme system
class ThemeState {
  /// Current theme type from available themes
  final ThemeType type;
  
  /// Current theme data containing colors and styles
  final AppThemeData theme;
  
  /// Whether theme is currently transitioning
  /// Used for animations and transitions
  final bool isChanging;

  const ThemeState({
    required this.type,
    required this.theme,
    this.isChanging = false,
  });

  /// Creates a copy of the current state with optional parameter overrides
  ThemeState copyWith({
    ThemeType? type,
    AppThemeData? theme,
    bool? isChanging,
  }) {
    return ThemeState(
      type: type ?? this.type,
      theme: theme ?? this.theme,
      isChanging: isChanging ?? this.isChanging,
    );
  }
}

/// Manages theme state and provides theme-related functionality
class ThemeCubit extends Cubit<ThemeState> {
  /// SharedPreferences instance for persisting theme selection
  final SharedPreferences prefs;
  
  /// Key used to store theme preference
  static const String _themeKey = 'app_theme';

  /// Creates a ThemeCubit with initial theme from preferences
  /// Falls back to darkMinimal if no theme is saved
  ThemeCubit(this.prefs) : super(
    ThemeState(
      type: ThemeType.values.byName(
        prefs.getString(_themeKey) ?? ThemeType.darkMinimal.name,
      ),
      theme: AppTheme.themes[ThemeType.darkMinimal]!,
    ),
  );

  /// Changes the current theme with animation
  /// Persists the selection to SharedPreferences
  void changeTheme(ThemeType type) {
    if (!AppTheme.themes.containsKey(type)) return;

    emit(state.copyWith(
      type: type,
      theme: AppTheme.themes[type]!,
      isChanging: true,
    ));
    
    prefs.setString(_themeKey, type.name);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(state.copyWith(isChanging: false));
    });
  }

  /// Toggles between light and dark mode while preserving theme style
  /// Example: Dark Ocean -> Light Ocean
  void toggleThemeMode() {
    final currentTheme = state.type;
    final isDark = AppTheme.themes[currentTheme]!.tags.contains(ThemeTag.dark);
    
    // Find corresponding theme in opposite mode
    final newTheme = AppTheme.themes.entries.firstWhere(
      (entry) => 
        entry.value.tags.contains(isDark ? ThemeTag.light : ThemeTag.dark) &&
        entry.value.tags.any((tag) => 
          AppTheme.themes[currentTheme]!.tags.contains(tag) &&
          tag != ThemeTag.dark &&
          tag != ThemeTag.light
        ),
      orElse: () => MapEntry(
        isDark ? ThemeType.lightMinimal : ThemeType.darkMinimal,
        AppTheme.themes[isDark ? ThemeType.lightMinimal : ThemeType.darkMinimal]!
      ),
    );
    
    changeTheme(newTheme.key);
  }

  /// Returns list of available themes for specified mode
  /// Used for theme selection UI
  List<ThemeType> getThemesForMode(bool isDark) {
    return AppTheme.themes.entries
      .where((entry) => entry.value.tags.contains(isDark ? ThemeTag.dark : ThemeTag.light))
      .map((e) => e.key)
      .toList();
  }
} 