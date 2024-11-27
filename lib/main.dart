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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(prefs),
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