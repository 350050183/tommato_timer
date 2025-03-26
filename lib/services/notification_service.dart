import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/timer_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showSessionCompletedNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'tomato_time_channel',
          'Tomato Time Notifications',
          channelDescription: 'Notifications for tomato time sessions',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> showWorkSessionCompleted(String message) async {
    await showSessionCompletedNotification('工作阶段已完成', message);
  }

  Future<void> showBreakCompleted(String message) async {
    await showSessionCompletedNotification('休息时间已结束', message);
  }
}
