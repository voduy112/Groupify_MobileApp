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

  Future<List<User>> getChatList(String userId) async {
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
  }
}
