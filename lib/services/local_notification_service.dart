import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ismatov/main.dart';
import 'dart:convert';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("Mahalliy bildirishnoma bosildi: ${response.payload}");
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = Map<String, dynamic>.from(jsonDecode(response.payload!));
            print("Parsed payload: $data"); // Debug
            if (data.containsKey('notification_type')) {
              final message = RemoteMessage(data: data);
              MyApp.handleNotificationNavigation(message);
            } else {
              print("Xato: notification_type topilmadi");
            }
          } catch (e) {
            print("Payloadni parse qilishda xato: $e");
          }
        } else {
          print("Payload null yoki bo'sh");
        }
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'snaplife_channel',
          'SnapLife Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      print("Mahalliy bildirishnoma ko‘rsatishda xato: $e");
    }
  }
}