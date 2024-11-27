import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_theme.dart';

class ThemePreviewCard extends StatelessWidget {
  final ThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.themes[theme]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? themeData.accent : themeData.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeData.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildColorCircle(themeData.accent),
                      const SizedBox(width: 8),
                      _buildColorCircle(themeData.accentLight),
                      const SizedBox(width: 8),
                      _buildColorCircle(themeData.accentSecondary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeData.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeData.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.palette_outlined,
                            color: themeData.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getThemeName(theme),
                              style: TextStyle(
                                color: themeData.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Dark Theme',
                              style: TextStyle(
                                color: themeData.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getThemeName(ThemeType theme) {
    switch (theme) {
      case ThemeType.midnight:
        return 'Midnight Blue';
      case ThemeType.eclipse:
        return 'Eclipse Dark';
      case ThemeType.aurora:
        return 'Aurora Green';
      case ThemeType.sunset:
        return 'Sunset Orange';
      case ThemeType.ocean:
        return 'Ocean Blue';
      case ThemeType.lavender:
        return 'Lavender Purple';
    }
  }
} 