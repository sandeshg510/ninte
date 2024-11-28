import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sound_service.dart';
import '../services/pomodoro_firestore_service.dart';
import '../services/notification_service.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final pomodoroFirestoreProvider = Provider<PomodoroFirestoreService>((ref) {
  return PomodoroFirestoreService();
});

final notificationServiceProvider = Provider<PomodoroNotificationService>((ref) {
  PomodoroNotificationService.init();
  ref.onDispose(() => PomodoroNotificationService.cancelAll());
  return PomodoroNotificationService();
}); 