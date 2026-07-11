import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../features/reminders/data/models/reminder_model.dart';
import 'hive_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // Dynamically detect device timezone from offset
    // Map UTC offset to an IANA timezone for accurate scheduling
    final offset = DateTime.now().timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    // Etc/GMT uses inverted sign (positive offset = west, negative = east)
    final invertedHours = (-totalMinutes / 60).round();
    final sign = invertedHours >= 0 ? '+' : '';
    final tzId = 'Etc/GMT$sign$invertedHours';
    try {
      tz.setLocalLocation(tz.getLocation(tzId));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'remindly_channel',
      'Remindly Notifications',
      description: 'Notifications for your reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permission (Android 13+)
    await android?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    await android?.requestExactAlarmsPermission();
  }

  /// Reschedule all existing reminders - call on app startup
  static Future<void> rescheduleAll() async {
    try {
      await _notifications.cancelAll();
      final reminders = HiveService.getAllReminders();
      for (final reminder in reminders) {
        if (!reminder.isCompleted) {
          await scheduleReminder(reminder);
        }
      }
      debugPrint('Rescheduled ${reminders.length} reminders');
    } catch (e) {
      debugPrint('Reschedule all failed: $e');
    }
  }

  static Future<void> scheduleReminder(ReminderModel reminder) async {
    // Cancel existing notifications for this reminder
    await cancelReminder(reminder.id);

    // Schedule notification at exact time
    await _scheduleNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: 'Reminder: ${reminder.title}',
      scheduledDate: reminder.dateTime,
      repeatType: reminder.repeatType,
    );

    // Schedule advance notifications (only for non-repeating reminders)
    if (reminder.repeatType == 'None') {
      for (final offset in reminder.notifyOffsets) {
        if (offset == 0) continue; // Skip same-day, already scheduled
        final advanceDate = reminder.dateTime.subtract(Duration(days: offset));
        if (advanceDate.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: '${reminder.id}_$offset'.hashCode,
            title: reminder.title,
            body: '$offset day${offset > 1 ? 's' : ''} remaining: ${reminder.title}',
            scheduledDate: advanceDate,
            repeatType: 'None',
          );
        }
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String repeatType,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // Skip if scheduled time is in the past
      if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Skipping past notification: $title at $tzDateTime');
        return;
      }

      debugPrint('Scheduling notification: $title at $tzDateTime (id: $id)');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'remindly_channel',
            'Remindly Notifications',
            channelDescription: 'Notifications for your reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification',
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: _getRepeatComponents(repeatType),
      );

      debugPrint('Successfully scheduled: $title (id: $id)');
    } catch (e) {
      debugPrint('Failed to schedule notification "$title" (id: $id): $e');
    }
  }

  static DateTimeComponents? _getRepeatComponents(String repeatType) {
    switch (repeatType) {
      case 'Daily':
        return DateTimeComponents.time;
      case 'Weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'Monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'Yearly':
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  static Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
    // Cancel advance notifications
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel('${id}_$i'.hashCode);
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
