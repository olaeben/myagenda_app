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
  }) async {
    try {
      final now = DateTime.now();
      final location = tz.local;

      // Schedule daily reminder if deadline is in the future
      if (deadline.isAfter(now.add(const Duration(days: 1)))) {
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
              '$title is due on ${DateFormat('MMM d, HH:mm').format(deadline)}',
          scheduledDate: tz.TZDateTime.from(dailyReminder, location),
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      // Schedule 15-minute reminder
      final reminderTime = deadline.subtract(const Duration(minutes: 15));
      if (reminderTime.isAfter(now)) {
        await _scheduleNotification(
          id: id,
          title: 'Upcoming Agenda',
          body: '$title is due in 15 minutes',
          scheduledDate: tz.TZDateTime.from(reminderTime, location),
        );
      }

      // Immediate notification for close deadlines
      if (deadline.difference(now).inMinutes < 15 && deadline.isAfter(now)) {
        await _scheduleNotification(
          id: id,
          title: 'Upcoming Agenda',
          body: '$title is due soon at ${DateFormat('HH:mm').format(deadline)}',
          scheduledDate:
              tz.TZDateTime.from(now.add(const Duration(seconds: 2)), location),
        );
      }

      // Deadline notification
      if (deadline.isAfter(now)) {
        await _scheduleNotification(
          id: id + 1000,
          title: 'Agenda Due',
          body: '$title deadline has arrived',
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
            'My Agenda Notifications',
            channelDescription: 'Notifications for My Agenda app',
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
    await _notifications.cancel(id); // Cancel 1-minute reminder
    await _notifications.cancel(id + 1000); // Cancel deadline notification
    await _notifications.cancel(id + 2000); // Cancel daily reminder
  }
}
