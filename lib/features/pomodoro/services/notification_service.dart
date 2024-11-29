import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_theme.dart';
import 'package:ninte/presentation/theme/app_theme_data.dart';
import 'package:ninte/presentation/theme/theme_cubit.dart';
import 'dart:developer' as dev;
import 'dart:isolate';
import 'dart:ui';
import 'dart:math';

class PomodoroNotificationService {
  static const _channelKey = 'pomodoro_timer';
  static NotificationActionCallback? _actionCallback;
  static late ThemeCubit _themeCubit;
  static const String _isolateName = 'pomodoro_isolate';
  static ReceivePort? _receivePort;
  static bool _isInBackground = false;

  static const _workCompleteMessages = [
    'Great Work! 🎉 Time for a break!',
    'Session Complete! 💪 You\'ve earned your break!',
    'Excellent Focus! 🌟 Take a breather now.',
    'Mission Accomplished! 🚀 Rest time!',
  ];

  static const _breakCompleteMessages = [
    'Break Time\'s Up! 💪 Ready to crush another session?',
    'Refreshed and Ready? 🎯 Let\'s get back to work!',
    'Break Complete! 🔄 Time to regain focus!',
    'Recharged! ⚡ Let\'s continue making progress!',
  ];

  static void setThemeCubit(ThemeCubit themeCubit) {
    _themeCubit = themeCubit;
  }

  static Future<void> init() async {
    try {
      final theme = _themeCubit.state.theme;
      
      // Set up background isolate communication
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
        _receivePort!.sendPort,
        _isolateName,
      );
      
      _receivePort!.listen(_handleIsolateMessage);
      
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: _channelKey,
            channelName: 'Pomodoro Timer',
            channelDescription: 'Shows timer notifications',
            defaultColor: theme.accent,
            ledColor: theme.accent,
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

      // Set up action stream
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _handleNotificationAction,
      );

      dev.log('Notification service initialized successfully');
    } catch (e) {
      dev.log('Error initializing notification service: $e');
    }
  }

  static void _handleIsolateMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      final actionId = message['actionId'] as String?;
      if (actionId != null) {
        _actionCallback?.call(actionId);
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleNotificationAction(ReceivedAction receivedAction) async {
    try {
      final sendPort = IsolateNameServer.lookupPortByName(_isolateName);
      if (sendPort != null) {
        sendPort.send({
          'actionId': receivedAction.buttonKeyPressed,
        });
      }
      
      // Handle action immediately if possible
      switch (receivedAction.buttonKeyPressed) {
        case 'PAUSE':
          _actionCallback?.call('pause');
          break;
        case 'STOP':
          _actionCallback?.call('stop');
          break;
        case 'START_BREAK':
          _actionCallback?.call('start_break');
          break;
        case 'START_WORK':
          _actionCallback?.call('start_work');
          break;
      }
    } catch (e) {
      dev.log('Error handling notification action: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        return await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return true;
    } catch (e) {
      dev.log('Error requesting notification permissions: $e');
      return false;
    }
  }

  static void setActionCallback(NotificationActionCallback callback) {
    _actionCallback = callback;
  }

  static void setBackgroundState(bool isBackground) {
    _isInBackground = isBackground;
    if (!isBackground) {
      // Cancel notifications when app comes to foreground
      cancelTimerNotification();
    }
  }

  static Future<void> showTimerRunningNotification({
    required int remainingSeconds,
    required String sessionType,
    required int totalSeconds,
  }) async {
    if (!_isInBackground) return;

    try {
      final theme = _themeCubit.state.theme;
      
      // Calculate progress more precisely using seconds
      final elapsedSeconds = totalSeconds - remainingSeconds;
      final progressPercentage = (elapsedSeconds / totalSeconds * 100).round();
      
      // Format time display
      final minutes = remainingSeconds ~/ 60;
      final seconds = remainingSeconds % 60;
      final timeDisplay = '$minutes:${seconds.toString().padLeft(2, '0')}';
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: _channelKey,
          title: 'Pomodoro Timer Running',
          body: '$sessionType - $timeDisplay remaining',
          category: NotificationCategory.Progress,
          notificationLayout: NotificationLayout.ProgressBar,
          progress: progressPercentage,
          color: theme.accent,
          backgroundColor: theme.surface,
          locked: true,
          autoDismissible: false,
          showWhen: true,
          displayOnBackground: true,
          displayOnForeground: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'PAUSE',
            label: 'Pause',
            color: theme.accent,
            autoDismissible: false,
          ),
          NotificationActionButton(
            key: 'STOP',
            label: 'Stop',
            color: theme.error,
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      dev.log('Error showing timer notification: $e');
    }
  }

  static Future<void> showTimerCompleteNotification({
    required String sessionType,
    required bool isWorkSession,
    required int dailySessions,
    required int dailyMinutes,
  }) async {
    try {
      final theme = _themeCubit.state.theme;
      
      final message = isWorkSession 
          ? _workCompleteMessages[Random().nextInt(_workCompleteMessages.length)]
          : _breakCompleteMessages[Random().nextInt(_breakCompleteMessages.length)];
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: _channelKey,
          title: 'Great Work! 🎉',
          body: '$message\n\nToday: $dailySessions sessions, $dailyMinutes minutes',
          category: NotificationCategory.Alarm,
          color: theme.accent,
          backgroundColor: theme.surface,
          notificationLayout: NotificationLayout.BigText,
          fullScreenIntent: true,
          criticalAlert: true,
          wakeUpScreen: true,
          customSound: 'work_complete',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'START_BREAK',
            label: 'Start Break',
            color: theme.accent,
            autoDismissible: true,
          ),
        ],
      );
    } catch (e) {
      dev.log('Error showing completion notification: $e');
    }
  }

  static Future<void> cancelTimerNotification() async {
    try {
      await AwesomeNotifications().cancel(1);
    } catch (e) {
      dev.log('Error canceling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelAll();
    } catch (e) {
      dev.log('Error canceling all notifications: $e');
    }
  }

  static Future<void> showStreakNotification({
    required int streakDays,
  }) async {
    if (!_isInBackground) return;

    try {
      final theme = _themeCubit.state.theme;
      String message;
      String emoji;

      // Customize message based on streak length
      if (streakDays >= 30) {
        message = 'Incredible! A whole month of consistency! 🌟';
        emoji = '🏆';
      } else if (streakDays >= 14) {
        message = 'Two weeks of dedication! Keep it up! ✨';
        emoji = '🔥';
      } else if (streakDays >= 7) {
        message = 'A full week of productivity! Amazing work! 🌟';
        emoji = '⭐';
      } else {
        message = '$streakDays days and counting! Stay focused! 💪';
        emoji = '📈';
      }

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 3, // Different ID for streak notifications
          channelKey: _channelKey,
          title: 'Streak Milestone! $emoji',
          body: message,
          category: NotificationCategory.Social,
          notificationLayout: NotificationLayout.BigText,
          color: theme.accent,
          backgroundColor: theme.surface,
        ),
      );
    } catch (e) {
      dev.log('Error showing streak notification: $e');
    }
  }

  static Future<void> cleanup() async {
    _receivePort?.close();
    IsolateNameServer.removePortNameMapping(_isolateName);
    await cancelAllNotifications();
  }
}

typedef NotificationActionCallback = void Function(String actionId); 