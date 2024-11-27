import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/gradient_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      context,
                      title: _getTitle(index),
                      description: _getDescription(index),
                      icon: _getIcon(index),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GradientButton(
                      text: 'Get Started',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return AppColors.withTheme(
      builder: (context, theme) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.accent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Welcome to Ninte';
      case 1:
        return 'Track Your Progress';
      case 2:
        return 'Stay Motivated';
      default:
        return '';
    }
  }

  String _getDescription(int index) {
    switch (index) {
      case 0:
        return 'Your personal habit tracking companion';
      case 1:
        return 'Monitor your daily habits and achievements';
      case 2:
        return 'Build better habits and reach your goals';
      default:
        return '';
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.waving_hand_rounded;
      case 1:
        return Icons.trending_up_rounded;
      case 2:
        return Icons.emoji_events_rounded;
      default:
        return Icons.circle;
    }
  }
} 