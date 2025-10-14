import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final instance = LocalNotificationService._();
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: handleLocalNotification,
    );
  }

  Future<void> showNoti({required String title, required String body}) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'chat',
          'chat',
          channelDescription: 'chat',
          importance: Importance.max,
          priority: Priority.high,
          channelShowBadge: true,
          autoCancel: true,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
    );
  }

  void handleLocalNotification(NotificationResponse messageResponse) async {
    log("Handle");
  }
}
