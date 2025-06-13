import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../models/group.dart';
import '../../../models/user.dart';
import '../../../services/api/dio_client.dart';

class GroupService {
  final Dio _dio;

  GroupService() : _dio = DioClient.instance;

  Future<List<Group>> getAllGroupbyUserId(String userId) async {
    try {
      final response = await _dio.get('/api/group/user/$userId');
      print("response getAllGroup: ${response.data}");

      if (response.statusCode == 200) {
        print(response.data); // In ra cấu trúc thực tế
        final List<dynamic> groupList = response.data is List
            ? response.data
            : response.data['data']; // Kiểm tra linh hoạt

        return groupList.map((json) => Group.fromJson(json)).toList();
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

  Future<List<Group>> getAllGroup(String userId) async {
    try {
      final response = await _dio.get('/api/group', queryParameters: {
        'userId': userId,
      });
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Group.fromJson(json))
            .toList();
      } else {
        throw Exception("Lỗi khi lấy danh sách nhóm: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi getAllGroup: $e");
      rethrow;
    }
  }

  Future<Group> joinGroupByCode(
      String groupId, String inviteCode, String userId) async {
    try {
      final response = await _dio.post(
        '/api/group/join',
        data: {
          'groupId': groupId,
          'inviteCode': inviteCode,
          'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        return Group.fromJson(response.data);
      } else {
        throw Exception("Tham gia nhóm thất bại: ${response.statusCode}");
      }
    } on DioException catch (e) {
      final serverError = e.response?.data?['error'] ?? 'Lỗi không xác định';

      if (serverError == "INVALID_INVITE_CODE") {
        throw Exception("Mã mời không đúng. Vui lòng kiểm tra lại.");
      }

      if (serverError.contains("đã tham gia nhóm")) {
        throw Exception("Bạn đã ở trong nhóm này rồi.");
      }

      throw Exception(serverError);
    } catch (e) {
      throw Exception("Lỗi khi tham gia nhóm: $e");
    }
  }

  Future<Group> createGroup({
    required String name,
    required String description,
    required String subject,
    required String inviteCode,
    required String ownerId,
    List<String>? membersID,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'subject': subject,
        'inviteCode': inviteCode,
        'ownerId': ownerId,
        if (membersID != null)
          for (int i = 0; i < membersID.length; i++)
            'membersID[$i]': membersID[i],
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'group_img.jpg',
        ),
      });

      final response = await _dio.post('/api/group/', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Group.fromJson(response.data);
      } else {
        throw Exception("Tạo nhóm thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi createGroup: $e");
      rethrow;
    }
  }

  Future<List<User>> getGroupMembers(String groupId) async {
  try {
    final response = await _dio.get('/api/group/members/$groupId/');
    if (response.statusCode == 200) {
      final List<dynamic> membersJson = response.data;
      return membersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception("Lỗi khi lấy danh sách thành viên: ${response.statusCode}");
    }
  } catch (e) {
    print("Lỗi getGroupMembers: $e");
    rethrow;
  }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
  try {
    final response = await _dio.post(
      '/api/group/leave',
      data: {
        'groupId': groupId,
        'userId': userId,
      },
    );

    if (response.statusCode == 200) {
      print("Rời nhóm thành công");
    } else {
      throw Exception("Rời nhóm thất bại: ${response.statusCode}");
    }
  } catch (e) {
    print("Lỗi leaveGroup: $e");
    rethrow;
  }
}

Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/group/remove-member',
        data: {
          'groupId': groupId,
          'memberId': memberId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Xoá thành viên thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi removeMember: $e");
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final response = await _dio.delete('/api/group/$groupId');
      if (response.statusCode != 200) {
        throw Exception("Xoá nhóm thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi deleteGroup: $e");
      rethrow;
    }
  }

  Future<Group> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required String subject,
    List<String>? membersID,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'subject': subject,
        if (membersID != null)
          for (int i = 0; i < membersID.length; i++)
            'membersID[$i]': membersID[i],
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'group_img.jpg',
          ),
      });

      final response = await _dio.put('/api/group/$groupId', data: formData);

      if (response.statusCode == 200) {
        return Group.fromJson(response.data);
      } else {
        throw Exception("Cập nhật nhóm thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi updateGroup: $e");
      rethrow;
    }
  }
  Future<Group> changeOwnerId(String groupId, String newOwnerId) async {
    try {
      final response = await _dio.post(
        '/api/group/change-owner',
        data: {
          'groupId': groupId,
          'newOwnerId': newOwnerId,
        },
      );

      if (response.statusCode == 200) {
        return Group.fromJson(response.data);
      } else {
        throw Exception("Chuyển quyền sở hữu thất bại: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi changeOwnerId: $e");
      rethrow;
    }
  }



}
