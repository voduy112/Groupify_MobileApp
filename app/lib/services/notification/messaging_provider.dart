import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/dio_client.dart';
import '../notification/messaging_service.dart';

class MessagingProvider extends ChangeNotifier {
  String? _adminFcmToken;

  String? get adminFcmToken => _adminFcmToken;

  Future<void> initialize() async {
    _adminFcmToken = await FirebaseMessaging.instance.getToken();
  }

  Future<void> sendJoinRequestNotification(
      String adminFcmToken, String userName, String groupName) async {
    if (adminFcmToken == null) {
      print("Admin FCM token is null");
      return;
    }
    await MessagingService.sendJoinRequestNotification(
        adminFcmToken, userName, groupName);
  }

  Future<void> sendAcceptJoinNotification(String userId, String groupId) async {
    if (userId == null || groupId == null) {
      print("User FCM token is null");
      return;
    }
    await MessagingService.sendAcceptJoinNotification(userId, groupId);
  }

  Future<void> sendPersonalChatNotification(
      String receiverId, String senderName, String message) async {
    print("receiverId provider: $receiverId");
    print("senderName provider: $senderName");
    print("message provider: $message");
    await MessagingService.sendPersonalChatNotification(
        receiverId, senderName, message);
  }
}
