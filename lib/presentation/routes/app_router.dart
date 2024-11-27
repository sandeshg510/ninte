import 'package:flutter/material.dart';
import 'package:ninte/presentation/pages/onboarding/onboarding_page.dart';
import 'package:ninte/presentation/pages/auth/auth_page.dart';
import 'package:ninte/presentation/pages/home/home_page.dart';
import 'package:ninte/presentation/routes/page_transitions.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String auth = '/auth';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return ThemeTransitionPage(
          page: const OnboardingPage(),
        );
      case auth:
        return ThemeTransitionPage(
          page: const AuthPage(),
        );
      case home:
        return ThemeTransitionPage(
          page: const HomePage(),
        );
      default:
        return ThemeTransitionPage(
          page: const OnboardingPage(),
        );
    }
  }
} 