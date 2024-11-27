import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_theme.dart';

class ThemeProvider extends InheritedWidget {
  final AppThemeData theme;

  const ThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  static AppThemeData of(BuildContext context) {
    final provider = context.findAncestorWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'No ThemeProvider found in context');
    return provider!.theme;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) => theme != oldWidget.theme;
} 