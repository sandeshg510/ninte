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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add lifecycle observer
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  
  final prefs = await SharedPreferences.getInstance();
  final themeCubit = ThemeCubit(prefs);
  
  // Set theme cubit for notifications
  PomodoroNotificationService.setThemeCubit(themeCubit);
  
  // Initialize notifications with proper error handling
  try {
    await PomodoroNotificationService.init();
    final hasPermission = await PomodoroNotificationService.requestPermissions();
    if (!hasPermission) {
      dev.log('Notification permissions not granted');
    }
  } catch (e) {
    dev.log('Error initializing notifications: $e');
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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

// Add this class to handle app lifecycle
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

  // Add dispose method
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
} 