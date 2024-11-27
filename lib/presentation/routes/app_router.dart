import 'package:flutter/material.dart';
import 'package:ninte/presentation/pages/auth/auth_page.dart';
import 'package:ninte/presentation/pages/home/home_page.dart';
import 'package:ninte/presentation/pages/profile/profile_page.dart';

class AppRouter {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
        
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
        
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
    }
  }
} 