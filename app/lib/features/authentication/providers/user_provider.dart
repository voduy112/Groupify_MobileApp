import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../services/user_service.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;
  User? get user => _user;
}
