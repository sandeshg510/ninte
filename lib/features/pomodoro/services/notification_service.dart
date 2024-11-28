import 'package:flutter/services.dart';
import 'dart:developer' as dev;

class PomodoroNotificationService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    dev.log('Notification service initialized (vibration only)');
  }

  static Future<void> showWorkCompleteNotification() async {
    try {
      // Pattern: heavy - delay - medium - delay - light
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.lightImpact();
      
      dev.log('Work complete notification (vibration) sent');
    } catch (e) {
      dev.log('Error showing work complete notification: $e');
    }
  }

  static Future<void> showBreakCompleteNotification() async {
    try {
      // Double vibration pattern
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      
      dev.log('Break complete notification (vibration) sent');
    } catch (e) {
      dev.log('Error showing break complete notification: $e');
    }
  }

  static Future<void> cancelAll() async {
    // Nothing to cancel for vibrations
  }
} 