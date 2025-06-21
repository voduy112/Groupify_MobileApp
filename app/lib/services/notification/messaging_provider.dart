import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/dio_client.dart';
import '../notification/messaging_service.dart';
import '../../models/notification.dart';

class MessagingProvider extends ChangeNotifier {
  String? _adminFcmToken;
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  String? get adminFcmToken => _adminFcmToken;

  Future<void> initialize() async {
    _adminFcmToken = await FirebaseMessaging.instance.getToken();
  }

  Future<List<dynamic>> getAllNotification(String userId) async {
    return await MessagingService.getAllNotification(userId);
  }

  Future<void> fetchAllNotification(String userId) async {
    final data = await MessagingService.getAllNotification(userId);
    _notifications = data
        .map<AppNotification>((json) => AppNotification.fromJson(json))
        .toList();
    notifyListeners();
  }

  Future<void> readNotification(String notiId) async {
    await MessagingService.readNotification(notiId);
    // Cập nhật lại trạng thái đã đọc
    final noti = _notifications.firstWhere((n) => n.id == notiId);
    if (noti != null) {
      noti.isRead = true;
      notifyListeners();
    }
  }

  Future<void> sendJoinRequestNotification(String adminFcmToken,
      String userName, String groupName, String groupId, String userId) async {
    if (adminFcmToken == null) {
      print("Admin FCM token is null");
      return;
    }
    await MessagingService.sendJoinRequestNotification(
        adminFcmToken, userName, groupName, groupId, userId);
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

  Future<void> sendGroupDocumentNotification(
      String adminName, String groupId, String documentTitle) async {
    await MessagingService.sendGroupDocumentNotification(
        adminName, groupId, documentTitle);
  }

  Future<void> muteGroup(String groupId, String userId) async {
    await MessagingService.muteGroup(groupId, userId);
  }

  Future<void> unmuteGroup(String groupId, String userId) async {
    await MessagingService.unmuteGroup(groupId, userId);
  }

  Future<List<dynamic>> getMutedGroups(String userId) async {
    return await MessagingService.getMutedGroups(userId);
  }
}
