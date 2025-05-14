import 'package:flutter/material.dart';
import './service/userService.dart';
import './models/user.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh sách người dùng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListScreen(), // Màn hình chính của ứng dụng
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserService userService;
  late Future<List<User>> usersFuture; // Cập nhật kiểu dữ liệu

  @override
  void initState() {
    super.initState();
    userService = UserService(
        baseUrl: 'http://192.168.1.234:5000'); // Dùng IP của máy tính cá nhân
    usersFuture = userService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách người dùng')),
      body: FutureBuilder<List<User>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có người dùng nào'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(user.username ?? 'Tên không xác định'),
                    SizedBox(width: 10),
                    Text(user.phoneNumber ?? 'Số điện thoại không xác định'),
                  ],
                ), // Đảm bảo `name` là thuộc tính của đối tượng User
                subtitle: Text(user.email ?? ''), // Kiểm tra giá trị của email
              );
            },
          );
        },
      ),
    );
  }
}
