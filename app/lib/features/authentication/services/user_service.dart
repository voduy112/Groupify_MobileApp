import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/user.dart';
import '../../../services/api/dio_client.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/user_provider.dart';
import 'dart:io';

class UserService {
  final Dio _dio;

  UserService() : _dio = DioClient.instance;

  Future<User> updateUser(String id, User user, {File? avatarImage}) async {
    try {
      print("user gửi lên: ${user.toJson()}");
      print("avatarImage: $avatarImage");
      dynamic dataToSend;

      if (avatarImage != null) {
        // Tạo map chỉ chứa các trường cần update, KHÔNG gửi profilePicture
        final userMap = user.toJson();
        userMap.remove('profilePicture'); // Xóa trường này nếu có

        // Xóa các trường null (Dio sẽ lỗi nếu value là null)
        userMap.removeWhere((key, value) => value == null);

        dataToSend = FormData.fromMap({
          ...userMap,
          if (avatarImage != null)
            'image': await MultipartFile.fromFile(avatarImage.path,
                filename: '${user.username}.jpg'),
        });
      } else {
        // Không có ảnh mới, gửi JSON bình thường
        dataToSend = user.toJson();
      }

      final response = await _dio.patch('/api/profile/$id', data: dataToSend);
      print("response: ${response.data}");
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin người dùng: $e');
    }
  }
}
