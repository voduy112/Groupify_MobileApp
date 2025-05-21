import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/user.dart';
import '../../../services/api/dio_client.dart';

class AuthService {
  final Dio _dio;

  AuthService() : _dio = DioClient.instance;

  /// Đăng nhập với email và password, trả về User nếu thành công
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login',
          data: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
}