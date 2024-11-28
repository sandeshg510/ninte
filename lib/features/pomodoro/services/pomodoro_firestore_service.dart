import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show max;
import 'dart:io';
import 'dart:developer' as dev;
import '../models/pomodoro_timer.dart';

class PomodoroFirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _maxRetries = 3;

  // Define validation ranges instead of functions
  static const _validationRanges = {
    'workDuration': {'min': 15, 'max': 60},
    'shortBreakDuration': {'min': 3, 'max': 30},
    'longBreakDuration': {'min': 15, 'max': 45},
    'sessionsBeforeLongBreak': {'min': 1, 'max': 8},
  };

  static const _defaultSettings = {
    'workDuration': 25,
    'shortBreakDuration': 5,
    'longBreakDuration': 15,
    'sessionsBeforeLongBreak': 4,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'autoStartBreaks': false,
    'autoStartPomodoros': false,
  };

  Future<void> saveSessionStats({
    required int dailySessions,
    required int dailyMinutes,
    required int totalSessions,
    required int totalMinutes,
    required int currentStreak,
    required int bestStreak,
    DateTime? lastSessionDate,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      final existingDoc = await _firestore.collection('users').doc(uid).get();
      final existingStats = existingDoc.data()?['pomodoroStats'] ?? {};

      final statsToSave = {
        'pomodoroStats': {
          'dailySessions': dailySessions,
          'dailyMinutes': dailyMinutes,
          'totalSessions': max(totalSessions, (existingStats['totalSessions'] as num?)?.toInt() ?? 0),
          'totalMinutes': max(totalMinutes, (existingStats['totalMinutes'] as num?)?.toInt() ?? 0),
          'currentStreak': max(currentStreak, (existingStats['currentStreak'] as num?)?.toInt() ?? 0),
          'bestStreak': max(bestStreak, (existingStats['bestStreak'] as num?)?.toInt() ?? 0),
          'lastSessionDate': (lastSessionDate ?? DateTime.now()).toIso8601String(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'appVersion': '1.0.0',
          'deviceInfo': {
            'platform': Platform.operatingSystem,
            'version': Platform.operatingSystemVersion,
            'timestamp': DateTime.now().toIso8601String(),
          },
        }
      };

      dev.log('Saving stats to Firebase: ${statsToSave.toString()}');
      
      await _firestore.collection('users').doc(uid).set(
        statsToSave,
        SetOptions(merge: true),
      );

      dev.log('Successfully saved stats to Firebase');
    } catch (e) {
      dev.log('Error saving stats: $e');
      throw 'Failed to save session stats';
    }
  }

  Future<Map<String, dynamic>?> getSessionStats() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      dev.log('Loading stats from Firebase...');

      final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

      final stats = doc.data()?['pomodoroStats'];
      if (stats != null) {
        dev.log('Loaded stats from Firebase: ${stats.toString()}');
        return stats;
      }
      return null;
    } catch (e) {
      dev.log('Error loading stats: $e');
      return null;
    }
  }

  void _validateStats(Map<String, dynamic> stats) {
    // Ensure all number fields are non-negative
    final numericFields = [
      'dailySessions',
      'dailyMinutes',
      'totalSessions',
      'totalMinutes',
      'currentStreak',
      'bestStreak',
    ];

    for (final field in numericFields) {
      if (stats[field] != null && stats[field] is num) {
        stats[field] = max(0, stats[field] as num);
      } else {
        stats[field] = 0;
      }
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': 'Could not get device info'};
    }
  }

  // Add method to clean up old data
  Future<void> cleanupOldData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

      final stats = doc.data()?['pomodoroStats'];
      if (stats == null) return;

      // Remove any invalid or old data
      stats.removeWhere((key, value) => value == null);

      await _firestore.collection('users').doc(uid).set({
        'pomodoroStats': stats,
      }, SetOptions(merge: true));

    } catch (e) {
      dev.log('Error cleaning up old data: $e');
    }
  }

  // Optional: Add a method to clean up old data structure
  Future<void> cleanupOldDataStructure() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      final stats = doc.data()?['pomodoroStats'];
      
      if (stats != null && stats['completedSessions'] != null) {
        // Remove the old field
        await _firestore.collection('users').doc(uid).update({
          'pomodoroStats.completedSessions': FieldValue.delete(),
        });
        dev.log('Cleaned up old data structure');
      }
    } catch (e) {
      dev.log('Error cleaning up old data: $e');
    }
  }

  // Add method to save settings
  Future<void> saveSettings(PomodoroTimer settings) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      // Log before validation
      dev.log('Attempting to save settings - Long Break Duration: ${settings.longBreakDuration}');

      final validatedSettings = {
        'pomodoroSettings': {
          'workDuration': settings.workDuration,
          'shortBreakDuration': settings.shortBreakDuration,
          'longBreakDuration': settings.longBreakDuration,  // Remove validation here
          'sessionsBeforeLongBreak': settings.sessionsBeforeLongBreak,
          'soundEnabled': settings.soundEnabled,
          'vibrationEnabled': settings.vibrationEnabled,
          'autoStartBreaks': settings.autoStartBreaks,
          'autoStartPomodoros': settings.autoStartPomodoros,
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      };

      dev.log('Saving settings to Firebase: ${validatedSettings['pomodoroSettings']}');

      await _firestore.collection('users').doc(uid).set(
        validatedSettings,
        SetOptions(merge: true),
      );

      // Verify saved data
      final savedDoc = await _firestore.collection('users').doc(uid).get();
      final savedSettings = savedDoc.data()?['pomodoroSettings'];
      dev.log('Verified saved settings - Long Break Duration: ${savedSettings?['longBreakDuration']}');

      dev.log('Settings saved successfully');
    } catch (e) {
      dev.log('Error saving settings: $e');
      throw 'Failed to save settings';
    }
  }

  // Add method to load settings
  Future<PomodoroTimer?> loadSettings() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      final doc = await _firestore.collection('users').doc(uid).get();
      final settings = doc.data()?['pomodoroSettings'];

      if (settings != null) {
        final longBreakDuration = (settings['longBreakDuration'] as num?)?.toInt() ?? 15;
        dev.log('Loading long break duration: $longBreakDuration');

        return PomodoroTimer(
          workDuration: (settings['workDuration'] as num?)?.toInt() ?? 25,
          shortBreakDuration: (settings['shortBreakDuration'] as num?)?.toInt() ?? 5,
          longBreakDuration: longBreakDuration,
          sessionsBeforeLongBreak: (settings['sessionsBeforeLongBreak'] as num?)?.toInt() ?? 4,
          soundEnabled: settings['soundEnabled'] as bool? ?? true,
          vibrationEnabled: settings['vibrationEnabled'] as bool? ?? true,
          autoStartBreaks: settings['autoStartBreaks'] as bool? ?? false,
          autoStartPomodoros: settings['autoStartPomodoros'] as bool? ?? false,
        );
      }
      
      dev.log('No settings found, using defaults');
      return null;
    } catch (e) {
      dev.log('Error loading settings: $e');
      return null;
    }
  }

  // Remove the validation method since we're handling validation in the UI
  // The UI already ensures values are within acceptable ranges
} 