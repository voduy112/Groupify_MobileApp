import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../socket/socket_provider.dart';
import '../services/auth_service.dart';
import 'dart:io';
import '../services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../services/api/dio_client.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.authService});

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> updateUser(String id, User user, {File? avatarImage}) async {
    _user = await _userService.updateUser(id, user, avatarImage: avatarImage);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<String?> login(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await authService.login(email, password);
      if (_user != null) {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await authService.updateFcmToken(_user!.id!, fcmToken);
        }

        final storage = FlutterSecureStorage();
        await storage.write(key: 'accessToken', value: _user!.accessToken!);
        await storage.write(key: 'refreshToken', value: _user!.refreshToken!);
        DioClient.resetRefreshFlag();
        DioClient.createInterceptors();

        final socketProvider =
            Provider.of<SocketProvider>(context, listen: false);
        socketProvider.connect(
          'http://192.168.1.174:5000',
          queryParams: {'userId': _user!.id!},
          token: _user!.accessToken,
        );
      }

      _error = null;
      return null;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Đã có lỗi xảy ra';
      return _error;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await authService.register(name, email, phone, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.logout(context);
      DioClient.resetRefreshFlag();

      final socketProvider =
          Provider.of<SocketProvider>(context, listen: false);
      socketProvider.disconnect();
    } catch (e) {
      _error = e.toString();
    } finally {
      final storage = FlutterSecureStorage();
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      await storage.deleteAll();
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> checkEmail(String email) async {
    try {
      final result = await authService.checkEmail(email);
      return result;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return e.toString();
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final result = await authService.verifyOTP(email, otp);
      return result == 'OTP verified successfully';
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> resendOTP(String email) async {
    try {
      final result = await authService.resendOTP(email);
      return result == 'OTP sent successfully';
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> changePassword(
      String email, String oldPassword, String newPassword) async {
    try {
      await authService.changePassword(email, oldPassword, newPassword);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> sendOTPEmail(String email) async {
    try {
      final result = await authService.sendOTPEmail(email);
      // So sánh chứa chuỗi hoặc chỉ cần không rỗng
      return result.toLowerCase().contains('otp') &&
          result.toLowerCase().contains('gửi');
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      await authService.resetPassword(email, newPassword);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
