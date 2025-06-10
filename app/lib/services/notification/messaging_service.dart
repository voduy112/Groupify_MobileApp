import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/api/dio_client.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> sendJoinRequestNotification(
      String adminFcmToken, String userName, String groupName) async {
    await DioClient.instance.post("/api/notification/send-join-request", data: {
      "adminFcmToken": adminFcmToken,
      "userName": userName,
      "groupName": groupName,
    });
  }

  static Future<void> sendAcceptJoinNotification(
      String userId, String groupId) async {
    await DioClient.instance.post("/api/notification/send-accept-join", data: {
      "userId": userId,
      "groupId": groupId,
    });
  }

  static Future<void> sendPersonalChatNotification(
      String receiverId, String senderName, String message) async {
    print("receiverId service: $receiverId");
    print("senderName service: $senderName");
    print("message service: $message");
    await DioClient.instance
        .post("/api/notification/send-personal-chat", data: {
      "receiverId": receiverId,
      "senderName": senderName,
      "message": message,
    });
  }

  static Future<void> sendGroupDocumentNotification(
      String adminName, String groupId, String documentTitle) async {
    print("adminName service: $adminName");
    print("groupId service: $groupId");
    print("documentTitle service: $documentTitle");
    await DioClient.instance
        .post("/api/notification/send-group-document", data: {
      "groupId": groupId,
      "adminName": adminName,
      "documentTitle": documentTitle,
    });
  }
}
