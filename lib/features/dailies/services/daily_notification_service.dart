import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/daily_task.dart';
import 'dart:developer' as dev;

class DailyNotificationService {
  static const String channelKey = 'daily_reminders';
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;  // Only initialize once
    
    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: channelKey,
            channelName: 'Daily Task Reminders',
            channelDescription: 'Notifications for daily tasks',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            ledOnMs: 1000,
            ledOffMs: 500,
            criticalAlerts: true,
          ),
        ],
        debug: true,
      );

      // Set up action stream only once
      if (!_isInitialized) {
        AwesomeNotifications().setListeners(
          onActionReceivedMethod: _handleNotificationAction,
        );
        _isInitialized = true;
      }

      dev.log('Daily notification service initialized successfully');
    } catch (e) {
      dev.log('Error initializing daily notification service: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleNotificationAction(ReceivedAction receivedAction) async {
    dev.log('Received daily notification action: ${receivedAction.buttonKeyPressed}');
  }

  static Future<void> scheduleReminder(DailyTask task) async {
    if (!task.hasReminder) return;

    try {
      final reminderTime = task.dueTime.subtract(Duration(minutes: task.reminderMinutes));
      if (reminderTime.isBefore(DateTime.now())) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: task.id.hashCode,
          channelKey: channelKey,
          title: 'Daily Task Reminder',
          body: 'Time to complete: ${task.title}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          criticalAlert: true,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(date: reminderTime),
      );

      dev.log('Scheduled reminder for task: ${task.title}');
    } catch (e) {
      dev.log('Error scheduling reminder: $e');
    }
  }

  static Future<void> cancelReminder(String taskId) async {
    try {
      await AwesomeNotifications().cancel(taskId.hashCode);
      dev.log('Cancelled reminder for task ID: $taskId');
    } catch (e) {
      dev.log('Error cancelling reminder: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        return await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return isAllowed;
    } catch (e) {
      dev.log('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Add cleanup method
  static Future<void> dispose() async {
    _isInitialized = false;
  }
} 