import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/pages/auth/login_page.dart';
import 'package:ninte/presentation/pages/auth/signup_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppColors.withTheme(
      builder: (context, theme) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                color: theme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.surfaceLight.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: TabBar(
                  indicatorColor: theme.accent,
                  indicatorWeight: 3,
                  labelColor: theme.accent,
                  unselectedLabelColor: theme.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
            ),
          ),
          body: const TabBarView(
            children: [
              LoginPage(),
              SignUpPage(),
            ],
          ),
        ),
      ),
    );
  }
} 