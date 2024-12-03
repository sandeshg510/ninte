import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninte/presentation/theme/app_theme.dart';

import '../../core/providers/shared_preferences_provider.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeType>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeType> {
  final SharedPreferences _prefs;
  static const _themeKey = 'selected_theme';

  ThemeNotifier(this._prefs) : super(_loadInitialTheme(_prefs));

  static ThemeType _loadInitialTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      try {
        return ThemeType.values.firstWhere(
          (type) => type.name == savedTheme,
        );
      } catch (_) {
        return ThemeType.eclipse;
      }
    }
    return ThemeType.eclipse;
  }

  Future<void> setTheme(ThemeType type) async {
    await _prefs.setString(_themeKey, type.name);
    state = type;
  }
} 