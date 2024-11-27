import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool _showLightThemes = false;

  void _applyTheme(ThemeType type, AppThemeData themeData) {
    HapticFeedback.mediumImpact();

    // Apply theme immediately
    context.read<ThemeCubit>().changeTheme(type);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: themeData.background.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutExpo,
          builder: (context, value, child) => Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: Opacity(
              opacity: value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: themeData.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: themeData.accent.withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Theme Preview Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeData.background,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Color Palette
                            Column(
                              children: [
                                _buildColorCircle(themeData.accent, 'Accent'),
                                const SizedBox(height: 12),
                                _buildColorCircle(themeData.accentLight, 'Light'),
                                const SizedBox(height: 12),
                                _buildColorCircle(themeData.accentSecondary, 'Secondary'),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Mock UI Elements
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [themeData.accent, themeData.accentLight],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 120,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: themeData.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: themeData.accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: themeData.accent,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: themeData.textPrimary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Loading Animation
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          children: [
                            // Rotating gradient arc
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1500),
                              builder: (context, value, child) => ShaderMask(
                                shaderCallback: (bounds) => SweepGradient(
                                  colors: [
                                    themeData.accent,
                                    themeData.accent.withOpacity(0.2),
                                  ],
                                  stops: [value, value],
                                  transform: GradientRotation(value * 6.28319), // 2*pi
                                ).createShader(bounds),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: themeData.accent.withOpacity(0.2),
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Center icon with pulse animation
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) => Transform.scale(
                                  scale: value,
                                  child: Icon(
                                    Icons.palette_outlined,
                                    color: themeData.accent,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Status Text with Typing Effect
                      DefaultTextStyle(
                        style: const TextStyle(
                          decoration: TextDecoration.none,
                        ),
                        child: TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: 'Applying your theme...'.length),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) => Text(
                            'Applying your theme...'.substring(0, value),
                            style: TextStyle(
                              color: themeData.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Apply theme with animation
    Future.delayed(const Duration(milliseconds: 500), () {
      // Add exit animation
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                Tween(begin: 1.0, end: 0.0).chain(
                  CurveTween(curve: Curves.easeOut),
                ),
              ),
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 1.0, end: 0.9).chain(
                    CurveTween(curve: Curves.easeOut),
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );

      // Navigate to home after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return AppColors.withTheme(
          builder: (context, theme) => Scaffold(
            backgroundColor: theme.background,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Theme Settings',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Theme Mode Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.surfaceLight.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton(
                            'Dark',
                            !_showLightThemes,
                            () => setState(() => _showLightThemes = false),
                            theme,
                          ),
                          _buildModeButton(
                            'Light',
                            _showLightThemes,
                            () => setState(() => _showLightThemes = true),
                            theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Theme List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: AppTheme.themes.entries
                          .where((e) => e.value.tags.contains(
                              _showLightThemes ? ThemeTag.light : ThemeTag.dark))
                          .length,
                      itemBuilder: (context, index) {
                        final entry = AppTheme.themes.entries
                            .where((e) => e.value.tags.contains(
                                _showLightThemes ? ThemeTag.light : ThemeTag.dark))
                            .elementAt(index);
                            
                        return _buildThemeCard(
                          entry.key, 
                          entry.value,
                          theme,
                          key: ValueKey('theme_$index'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AppThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.accent : theme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    ThemeType type,
    AppThemeData themeData,
    AppThemeData currentTheme, {
    Key? key,
  }) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isSelected = state.type == type;
        
        return GestureDetector(
          key: key,
          onTap: () => _applyTheme(type, themeData),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeData.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? themeData.accent : themeData.surfaceLight.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeData.accent.withOpacity(isSelected ? 0.2 : 0),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  themeData.name,
                  style: TextStyle(
                    color: themeData.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  themeData.description,
                  style: TextStyle(
                    color: themeData.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in themeData.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeData.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag.name.toUpperCase(),
                          style: TextStyle(
                            color: themeData.accent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorCircle(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 