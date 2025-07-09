import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')
        );
    _notificationsPlugin.initialize(initializationSettings);

  }
  static void display(RemoteMessage message) async {
    try{
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
        'snaplife_channel',
        'snaplife Notification',
        importance: Importance.max,
          priority: Priority.high,

        )
      );
      await _notificationsPlugin.show(id,
          message.notification?.title ?? 'New Notification',
          message.notification?.body ?? '',
          notificationDetails
      );
    } catch (e) {
      print('📛 Local notification error: $e');
    }
  }
}
