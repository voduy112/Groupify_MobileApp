import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/group.dart';
import '../../../services/api/dio_client.dart';

class GroupService {
  final Dio _dio;

  GroupService() : _dio = DioClient.instance;

  Future<List<Group>> getAllGroup(String userId) async {
    try {
      final response = await _dio.get('/api/group/user/$userId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        throw Exception("Lỗi khi lấy danh sách nhóm: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getAllGroup: $e");
      rethrow;
    }
  }

  Future<Group> getGroup(String groupId) async {
    try {
      final response = await _dio.get('/api/group/$groupId');
      if (response.statusCode == 200) {
        return Group.fromJson(response.data);
      } else {
        throw Exception("Lỗi khi lấy thông tin nhóm: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getGroup: $e");
      rethrow;
    }
  }
}
