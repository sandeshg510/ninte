import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ninte/firebase_options.dart';
import 'package:ninte/core/providers/shared_preferences_provider.dart';
import 'package:ninte/core/providers/auth_provider.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'package:ninte/core/app.dart';
import 'package:ninte/core/services/auth_service.dart';
import 'package:ninte/features/pomodoro/services/notification_service.dart';
import 'dart:developer' as dev;
import 'features/dailies/services/daily_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final themeCubit = ThemeCubit(prefs);
  
  // Set theme cubit for Pomodoro notifications
  PomodoroNotificationService.setThemeCubit(themeCubit);
  
  // Initialize both notification services
  try {
    // Initialize Pomodoro notifications
    await PomodoroNotificationService.init();
    
    // Initialize Daily notifications
    await DailyNotificationService.initialize();
    
    // Request permissions (will work for both services since they use the same plugin)
    final hasPermission = await DailyNotificationService.requestPermissions();
    if (!hasPermission) {
      dev.log('Notification permissions not granted');
    }
  } catch (e) {
    dev.log('Error initializing notifications: $e');
  }
  
  // Add lifecycle observer for Pomodoro background state
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  
  final authService = AuthService();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(
          value: themeCubit,
        ),
      ],
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authServiceProvider.overrideWithValue(authService),
        ],
        child: const NinteApp(),
      ),
    ),
  );
}

// Keep the AppLifecycleObserver for Pomodoro
class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        PomodoroNotificationService.setBackgroundState(true);
        break;
      case AppLifecycleState.resumed:
        PomodoroNotificationService.setBackgroundState(false);
        break;
      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
} 