import 'package:dio/dio.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../services/api/dio_client.dart';

class ChatService {
  final Dio _dio;

  ChatService() : _dio = DioClient.instance;

  Future<List<Message>> getMessages(String user1Id, String user2Id) async {
    try {
      final response = await _dio.get('/api/chat/$user1Id/$user2Id');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi API lấy tin nhắn: $e');
    }
  }

  /*Future<List<User>> getChatList(String userId) async {
    try {
      final response = await _dio.get('/api/chat/list/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy danh sách chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi API lấy danh sach chat: $e');
    }
  }*/

  Future<Map<String, dynamic>> getChatList(String userId,
      {int page = 1}) async {
    final res = await _dio.get('/api/chat/list/$userId?page=$page&limit=10');
    final List<dynamic> chatsJson = res.data['chats'];

    final users = <User>[];
    final lastMsgs = <String, String>{};

    for (var json in chatsJson) {
      final user = User.fromJson(json);
      users.add(user);
      final msg = json['lastMessage'] ?? '';
      final isSender = json['isSender'] ?? false;
      lastMsgs[user.id!] = isSender ? 'Bạn: $msg' : msg;
    }

    return {
      'chats': users,
      'lastMsgs': lastMsgs,
      'totalPages': res.data['totalPages'],
    };
  }

  Future<void> deleteChat(String userId1, String userId2) async {
    final response = await _dio.delete('/api/chat/$userId1/$userId2');
    if (response.statusCode != 200) {
      throw Exception('Xóa cuộc trò chuyện thất bại');
    }
  }

  Future<List<User>> searchChat(String userId, String query) async {
    try {
      final response = await _dio.get(
        '/api/chat/search',
        queryParameters: {'userId': userId, 'query': query},
      );

      final List data = response.data['chats'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm danh sách chat: $e');
    }
  }

}
