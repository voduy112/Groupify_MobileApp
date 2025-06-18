import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/group_message.dart';
import '../../../services/api/dio_client.dart';

class ChatgroupService {
  final Dio _dio;

  ChatgroupService() : _dio = DioClient.instance;

  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    try {
      final response = await _dio.get('/api/chatgroup/message/$groupId');

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

  //ham gui anh
  Future<GroupMessage> uploadImageAndReturnMessage(
    File imageFile, {
    required String fromUserId,
    required String groupId,
  }) async {
    try {
      final String fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(
            lookupMimeType(imageFile.path) ?? 'image/jpeg',
          ),
        ),
        'fromUserId': fromUserId, 
      });

      final response = await _dio.post(
        '/api/chatgroup/message/send-image/$groupId',
        data: formData,
      );

      if (response.statusCode == 200) {
        return GroupMessage.fromJson(response.data);
      } else {
        throw Exception('Upload ảnh thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }
}
