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
    final response = await _dio
        .post('/api/auth/login', data: {'email': email, 'password': password});

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      // Dio sẽ tự động ném ra lỗi cho các status code ngoài 2xx,
      // nên phần else này có thể không bao giờ được thực thi, nhưng để cho chắc chắn.
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['message'] ?? 'Đăng nhập thất bại',
      );
    }
  }

  Future<User> register(
      String name, String email, String phone, String password) async {
    final response = await _dio.post('/api/auth/register', data: {
      'username': name,
      'email': email,
      'phoneNumber': phone,
      'password': password,
    });
    return User.fromJson(response.data);
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

  Future<String> checkEmail(String email) async {
    try {
      final response =
          await _dio.post('/api/auth/check-email', data: {'email': email});
      return response.data['message'];
    } on DioError catch (e) {
      return e.response?.data['message'] ?? 'Error';
    }
  }

  Future<String> verifyOTP(String email, String otp) async {
    print("email đây: $email");
    print("otp đây: $otp");
    final response = await _dio
        .post('/api/auth/verify-otp', data: {'email': email, 'otp': otp});
    print("response đây: ${response.data}");
    return response.data['message'];
  }

  Future<String> resendOTP(String email) async {
    final response =
        await _dio.post('/api/auth/resend-otp', data: {'email': email});
    return response.data['message'];
  }

  //lay profile by userid
  Future<User> fetchUserProfileById(String userId) async {
    try {
      final response = await _dio.get('/api/profile/$userId');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> changePassword(
      String email, String oldPassword, String newPassword) async {
    try {
      final response = await _dio.post('/api/auth/change-password', data: {
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  Future<void> updateFcmToken(String userId, String fcmToken) async {
    final response = await _dio.post('/api/auth/update-fcm-token',
        data: {'userId': userId, 'fcmToken': fcmToken});
    return response.data;
  }

  Future<void> resetPassword(String email, String newPassword) async {
    try {
      final response = await _dio.post('/api/auth/reset-password', data: {
        'email': email,
        'newPassword': newPassword,
      });
      if (response.statusCode == 200) {
        return; // Thành công không trả gì đặc biệt
      } else {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }
  Future<String> sendOTPEmail(String email) async {
    try {
      final response =
          await _dio.post('/api/auth/send-otp-email', data: {'email': email});
      return response.data['message'];
    } on DioError catch (e) {
      return e.response?.data['message'] ?? 'Lỗi gửi OTP';
    }
  }

}
