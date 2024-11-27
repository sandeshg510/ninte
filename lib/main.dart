import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninte/core/app.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize default theme
  final themeIndex = prefs.getInt('selected_theme');
  final themeType = themeIndex != null ? ThemeType.values[themeIndex] : ThemeType.eclipse;
  final theme = AppTheme.themes[themeType]!;
  AppColors.setCurrentTheme(theme);
  
  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(prefs),
      child: const NinteApp(),
    ),
  );
} 