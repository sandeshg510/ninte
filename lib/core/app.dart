import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/routes/app_router.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/core/providers/auth_provider.dart';
import 'package:ninte/presentation/pages/auth/auth_page.dart';
import 'package:ninte/presentation/pages/home/home_page.dart';
import 'package:ninte/presentation/widgets/shimmer_loading.dart';

/// Root widget of the application
/// Handles theme management and routing
class NinteApp extends ConsumerStatefulWidget {
  const NinteApp({super.key});

  @override
  ConsumerState<NinteApp> createState() => _NinteAppState();
}

class _NinteAppState extends ConsumerState<NinteApp> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authService = ref.read(authServiceProvider);
    final isAuthenticated = await authService.isAuthenticated();
    setState(() {
      _initialRoute = isAuthenticated ? AppRouter.home : AppRouter.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => 
        previous.type != current.type || 
        previous.isChanging != current.isChanging,
      builder: (context, state) {
        final isDark = state.theme.tags.contains(ThemeTag.dark);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: state.theme.background,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));

        // If initial route is not determined yet, show shimmer loading
        if (_initialRoute == null) {
          return AppColors(
            theme: state.theme,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: state.theme.themeData,
              home: const ShimmerLoading(),
            ),
          );
        }

        return AppColors(
          theme: state.theme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: state.theme.themeData.copyWith(
              appBarTheme: AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                ),
              ),
            ),
            home: _buildInitialPage(),
            onGenerateRoute: (settings) {
              // Only handle subsequent routes after initial page is built
              if (settings.name == null) return null;
              return AppRouter.onGenerateRoute(settings);
            },
          ),
        );
      },
    );
  }

  Widget _buildInitialPage() {
    switch (_initialRoute) {
      case AppRouter.home:
        return const HomePage();
      case AppRouter.auth:
        return const AuthPage();
      default:
        return const AuthPage();
    }
  }
} 