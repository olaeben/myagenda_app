import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

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
    final now = DateTime.now();

    // Schedule daily reminder if deadline is in the future
    if (deadline.isAfter(now.add(const Duration(days: 1)))) {
      final dailyReminder = DateTime(
        now.year,
        now.month,
        now.day,
        deadline.hour,
        deadline.minute,
      ).add(const Duration(days: 1)); // Start from tomorrow

      await _notifications.zonedSchedule(
        id + 2000, // Different ID for daily reminder
        'Daily Agenda Reminder',
        '$title is due on ${DateFormat('MMM d, HH:mm').format(deadline)}',
        tz.TZDateTime.from(dailyReminder, tz.local),
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          android: const AndroidNotificationDetails(
            'myagenda_daily',
            'My Agenda Daily Reminders',
            channelDescription: 'Daily reminders for upcoming agenda items',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'notification_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // Schedule notification 15 minutes before deadline
    final reminderTime = deadline.subtract(const Duration(minutes: 15));
    if (reminderTime.isAfter(now)) {
      await _notifications.zonedSchedule(
        id,
        'Upcoming Agenda',
        '$title is due in 15 minutes',
        tz.TZDateTime.from(reminderTime, tz.local),
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
      );
    }

    // Schedule immediate notification if deadline is less than 15 minutes away
    if (deadline.difference(now).inMinutes < 15 && deadline.isAfter(now)) {
      await _notifications.zonedSchedule(
        id,
        'Upcoming Agenda',
        '$title is due soon at ${DateFormat('HH:mm').format(deadline)}',
        tz.TZDateTime.from(now.add(const Duration(seconds: 2)), tz.local),
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
      );
    }

    // Schedule notification at deadline
    if (deadline.isAfter(now)) {
      await _notifications.zonedSchedule(
        id + 1000,
        'Agenda Due',
        '$title deadline has arrived',
        tz.TZDateTime.from(deadline, tz.local),
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
      );
    }
  }

  Future<void> cancelNotifications(int id) async {
    await _notifications.cancel(id); // Cancel 1-minute reminder
    await _notifications.cancel(id + 1000); // Cancel deadline notification
    await _notifications.cancel(id + 2000); // Cancel daily reminder
  }
}
