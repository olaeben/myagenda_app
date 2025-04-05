import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show debugPrint;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}

  Future<void> initNotification() async {
    // Initialize settings for Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/notification_icon');

    // Initialize settings for iOS
    const DarwinInitializationSettings iOSinitializationSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Combine Android and iOS Initialization Settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSinitializationSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    // Request permissions for android
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDeadlineNotifications({
    required int id,
    required String title,
    required DateTime deadline,
    String frequency = 'Daily',
    List<bool>? selectedDays,
  }) async {
    try {
      final now = DateTime.now();
      if (deadline.isBefore(now)) {
        await cancelNotifications(id);
        return;
      }

      final location = tz.local;

      if (frequency.toLowerCase() == 'daily' &&
          deadline.isAfter(now.add(const Duration(days: 1)))) {
        final dailyReminder = DateTime(
          now.year,
          now.month,
          now.day,
          deadline.hour,
          deadline.minute,
        ).add(const Duration(days: 1));

        await _scheduleNotification(
          id: id + 2000,
          title: 'Daily Agenda Reminder',
          body:
              'Your agenda "$title" is due on ${DateFormat('MMM d, HH:mm').format(deadline)}',
          scheduledDate: tz.TZDateTime.from(dailyReminder, location),
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (frequency.toLowerCase() == 'custom' &&
          selectedDays != null &&
          selectedDays.contains(true)) {
        final List<int> selectedDayIndices = [];
        for (int i = 0; i < selectedDays.length; i++) {
          if (selectedDays[i]) selectedDayIndices.add(i);
        }

        for (int i = 0; i < selectedDayIndices.length; i++) {
          final dayIndex = selectedDayIndices[i];
          final weekday = dayIndex + 1;

          DateTime nextOccurrence = now;
          while (nextOccurrence.weekday != weekday ||
              nextOccurrence.isBefore(now)) {
            nextOccurrence = nextOccurrence.add(const Duration(days: 1));
          }

          if (nextOccurrence.isBefore(deadline)) {
            final customReminder = DateTime(
              nextOccurrence.year,
              nextOccurrence.month,
              nextOccurrence.day,
              deadline.hour,
              deadline.minute,
            );

            await _scheduleNotification(
              id: id + 2000 + i,
              title: 'Custom Agenda Reminder',
              body:
                  'Your agenda "$title" is due on ${DateFormat('MMM d, HH:mm').format(deadline)}',
              scheduledDate: tz.TZDateTime.from(customReminder, location),
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
        }
      }

      // Schedule 15-minute reminder
      final reminderTime = deadline.subtract(const Duration(minutes: 15));
      if (reminderTime.isAfter(now)) {
        await _scheduleNotification(
          id: id,
          title: 'Upcoming Agenda',
          body: 'Your agenda "$title" is due in 15 minutes',
          scheduledDate: tz.TZDateTime.from(reminderTime, location),
        );
      }

      if (deadline.difference(now).inMinutes < 15 && deadline.isAfter(now)) {
        await _scheduleNotification(
          id: id,
          title: 'Upcoming Agenda',
          body:
              'Your agenda "$title" is due soon at ${DateFormat('HH:mm').format(deadline)}',
          scheduledDate:
              tz.TZDateTime.from(now.add(const Duration(seconds: 2)), location),
        );
      }

      // Deadline notification
      if (deadline.isAfter(now)) {
        await _scheduleNotification(
          id: id + 1000,
          title: 'Agenda Due',
          body: 'Your agenda "$title" deadline has arrived',
          scheduledDate: tz.TZDateTime.from(deadline, location),
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          android: const AndroidNotificationDetails(
            'myagenda_notifications',
            'AgendifyNow Notifications',
            channelDescription: 'Notifications for AgendifyNow app',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'notification_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (e) {
      debugPrint('Error in _scheduleNotification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotifications(int id) async {
    try {
      await _notifications.cancel(id);
      await _notifications.cancel(id + 1000);
      await _notifications.cancel(id + 2000);

      for (int i = 1; i <= 5; i++) {
        await _notifications.cancel(id + (i * 1000));
      }
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}
