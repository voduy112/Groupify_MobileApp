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
}
