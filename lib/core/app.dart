import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninte/presentation/routes/app_router.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class NinteApp extends StatelessWidget {
  const NinteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => 
        previous.type != current.type || 
        previous.isChanging != current.isChanging,
      builder: (context, state) {
        return AnimatedTheme(
          data: state.theme.themeData,
          duration: const Duration(milliseconds: 300),
          child: MaterialApp(
            theme: state.theme.themeData,
            home: Navigator(
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRouter.onboarding,
            ),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return AppColors.withTheme(
                builder: (context, theme) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: theme.background,
                  child: child!,
                ),
              );
            },
          ),
        );
      },
    );
  }
} 