import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const String _allUsersTopic = 'all_users';

  static const List<String> _motivationalMessages = [
    'Every expert was once a beginner. Keep going! 💪',
    'A little progress each day adds up to big results. 🚀',
    'Your future robot-building self will thank you for today. 🤖',
    'Consistency beats intensity. Just show up today! ⭐',
    'You didn\'t come this far to only come this far. Keep learning!',
    'Small steps every day lead to big achievements. 🔧',
    'The best time to learn was yesterday. The next best time is now!',
  ];

  /// Call this once when the app starts (e.g. in main.dart after Firebase.initializeApp())
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (_) {}

    // Set up local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Create a notification channel (required on Android 8+)
    const channel = AndroidNotificationChannel(
      'main_channel',
      'General Notifications',
      description: 'Course reminders and announcements',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Show a local notification whenever a push notification arrives in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        message.notification?.title ?? 'One Robotics Ai',
        message.notification?.body ?? '',
      );
    });

    try {
      await _messaging.subscribeToTopic(_allUsersTopic);
    } catch (_) {}

    // Schedule the recurring "every 5 hours" motivational reminders
    await _scheduleMotivationalReminders();

    final token = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
      print('Subscribed to topic: $_allUsersTopic');
    }
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      channelDescription: 'Course reminders and announcements',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Call this to show an instant reminder (e.g. on login/signup)
  static Future<void> showReminderNow(String title, String body) async {
    await _showLocalNotification(title, body);
  }

  /// Schedules motivational notifications every 5 hours, repeating for the
  /// next several days. Re-run on every app start to keep the schedule fresh.
  static Future<void> _scheduleMotivationalReminders() async {
    // Clear previously scheduled motivational reminders so we don't duplicate them
    for (int i = 0; i < 40; i++) {
      await _localNotifications.cancel(9000 + i); // reserved ID range for these
    }

    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      channelDescription: 'Motivational learning reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);

    // Schedule the next 20 occurrences, 5 hours apart (~4 days ahead)
    for (int i = 1; i <= 20; i++) {
      final scheduledTime = now.add(Duration(hours: 5 * i));
      final message = _motivationalMessages[i % _motivationalMessages.length];

      await _localNotifications.zonedSchedule(
        9000 + i,
        'Keep Learning! 🌟',
        message,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (kDebugMode) {
      print('Scheduled 20 motivational reminders, every 5 hours.');
    }
  }
}