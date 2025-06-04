import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/grouprequest.dart';
import '../../../services/api/dio_client.dart';

class GroupRequestService {
  final Dio _dio;

  GroupRequestService() : _dio = DioClient.instance;

   Future<Grouprequest?> createGroupRequest(String groupId, String userId) async {
  try {
    final response = await _dio.post('/api/grouprequest/', data: {
      'groupId': groupId,
      'userId': userId,
    });
    return Grouprequest.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 409) {
      print("Yêu cầu đã tồn tại");
      throw Exception("isExist"); 
    } else {
      print("Lỗi khác khi tạo yêu cầu vào nhóm: $e");
      return null;
    }
  } catch (e) {
    print("Lỗi không xác định: $e");
    return null;
  }
}

  Future<bool> approveGroupRequest(String requestId) async {
    try {
      final response = await _dio.post('/api/grouprequest/$requestId');
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi duyệt yêu cầu: $e');
      return false;
    }
  }

  Future<bool> deleteRequest(String requestId) async {
    try {
      final response = await _dio.delete('/api/grouprequest/$requestId');
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi xóa yêu cầu: $e');
      return false;
    }
  }

  Future<List<Grouprequest>> getAllRequestsByGroupId(String groupId) async {
  try {
    final response = await _dio.get('/api/grouprequest/group/$groupId');
    final List data = response.data;
    return data.map((json) => Grouprequest.fromJson(json)).toList();
  } catch (e) {
    print('Lỗi khi lấy yêu cầu theo groupId: $e');
    return [];
  }
}

}
