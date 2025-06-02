import 'package:dio/dio.dart';
import '../../../models/group_message.dart';
import '../../../services/api/dio_client.dart';

class ChatgroupService {
  final Dio _dio;

  ChatgroupService() : _dio = DioClient.instance;

  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    try {
      final response = await _dio.get('/chatgroup/messages/$groupId');

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => GroupMessage.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi lấy tin nhắn nhóm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch sử nhóm: $e');
    }
  }
}