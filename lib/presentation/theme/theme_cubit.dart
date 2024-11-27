import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';

class ThemeState {
  final ThemeType type;
  final AppThemeData theme;
  final bool isChanging;

  ThemeState({
    required this.type,
    required this.theme,
    this.isChanging = false,
  });

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

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'selected_theme';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeState(
    type: ThemeType.eclipse,
    theme: AppTheme.defaultTheme,
  )) {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null) {
      final type = ThemeType.values[themeIndex];
      final theme = AppTheme.themes[type]!;
      _updateTheme(type, theme);
    }
  }

  void changeTheme(ThemeType type) {
    if (type == state.type) return;
    
    // Start theme change
    emit(state.copyWith(isChanging: true));
    
    final theme = AppTheme.themes[type]!;
    _prefs.setInt(_themeKey, type.index);

    // Update colors first
    AppColors.setCurrentTheme(theme);
    
    // Update system UI
    AppTheme.setSystemUIOverlayStyle(theme);
    
    // Complete theme change
    emit(ThemeState(
      type: type,
      theme: theme,
      isChanging: false,
    ));

    // Force a rebuild after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emit(ThemeState(
        type: type,
        theme: theme,
        isChanging: false,
      ));
    });
  }

  void _updateTheme(ThemeType type, AppThemeData theme) {
    // Start theme change
    emit(state.copyWith(isChanging: true));
    
    // Update colors first
    AppColors.setCurrentTheme(theme);
    
    // Update system UI
    AppTheme.setSystemUIOverlayStyle(theme);
    
    // Complete theme change
    emit(ThemeState(
      type: type,
      theme: theme,
      isChanging: false,
    ));
  }
} 