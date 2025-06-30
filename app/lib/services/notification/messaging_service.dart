import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/api/dio_client.dart';

class MessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<List<dynamic>> getAllNotification(String userId) async {
    final response =
        await DioClient.instance.get('/api/notification/user/$userId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['notifications'];
    } else {
      throw Exception('Không thể lấy danh sách thông báo');
    }
  }

  static Future<void> readAllNotification(String userId) async {
    await DioClient.instance.post('/api/notification/read-all/$userId');
  }

  static Future<void> readNotification(String notiId) async {
    await DioClient.instance.post('/api/notification/read/$notiId');
  }

  static Future<void> sendJoinRequestNotification(String adminFcmToken,
      String userName, String groupName, String groupId, String userId) async {
    await DioClient.instance.post("/api/notification/send-join-request", data: {
      "adminFcmToken": adminFcmToken,
      "userName": userName,
      "groupName": groupName,
      "groupId": groupId,
      "userId": userId,
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

  static Future<void> sendQuizNotification(
      String groupId, String quizTitle) async {
    await DioClient.instance.post("/api/notification/send-quiz", data: {
      "groupId": groupId,
      "quizTitle": quizTitle,
    });
  }

  static Future<void> muteGroup(String groupId, String userId) async {
    await DioClient.instance.post("/api/notification/mute-group", data: {
      "groupId": groupId,
      "userId": userId,
    });
  }

  static Future<void> unmuteGroup(String groupId, String userId) async {
    await DioClient.instance.post("/api/notification/unmute-group", data: {
      "groupId": groupId,
      "userId": userId,
    });
  }

  static Future<List<dynamic>> getMutedGroups(String userId) async {
    final response =
        await DioClient.instance.get("/api/notification/muted-groups/$userId");
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['groups'];
    } else {
      throw Exception('Không thể lấy danh sách nhóm đã tắt thông báo');
    }
  }

  static Future<bool> isGroupMuted(String userId, String groupId) async {
    final response = await DioClient.instance
        .get("/api/notification/is-group-muted/$userId/$groupId");
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['isMuted'] == true;
    } else {
      throw Exception('Không thể kiểm tra trạng thái mute của nhóm');
    }
  }
}
