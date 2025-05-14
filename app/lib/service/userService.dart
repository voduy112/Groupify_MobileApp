import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/profile/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
