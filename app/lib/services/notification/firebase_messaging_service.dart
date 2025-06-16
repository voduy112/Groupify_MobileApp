import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  static Future<void> initFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = message.notification!;
        showSimpleNotification(
          Text(notification.title ?? 'Thông báo'),
          subtitle: Text(notification.body ?? ''),
          background: Colors.blue,
        );
      }
    });
  }
}
