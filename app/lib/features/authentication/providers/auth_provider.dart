import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../services/auth_service.dart';
import 'dart:io';
import '../services/user_service.dart';

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

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await authService.login(email, password);
      _error = null;
      return null;
    } catch (e) {
      _error = e.toString();
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
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
