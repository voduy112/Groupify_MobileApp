import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../models/user.dart';
import '../../../services/api/dio_client.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class AuthService {
  final Dio _dio;

  AuthService() : _dio = DioClient.instance;

  /// Đăng nhập với email và password, trả về User nếu thành công
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login',
          data: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        print("User: ${response.data}");
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final token = context.read<AuthProvider>().user?.accessToken;
      print("Token: $token");
      final response = await _dio.post('/api/auth/logout',
          options: Options(headers: {'token': 'Bearer $token'}));
      print("Logout response: ${response.data}");
      if (response.statusCode == 200) {
        print("Logout successful");
        context.read<AuthProvider>().clearUser();
        context.read<AuthProvider>().notifyListeners();
      }
    } catch (e) {
      throw Exception('Error logging out: $e');
    }
  }
}
