import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../features/authentication/providers/user_provider.dart';
import '../../../features/home/views/home_screen.dart';
import '../../../core/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đăng nhập'),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.login(
                  emailController.text,
                  passwordController.text,
                );

                final user = authProvider.user;
                print(user!.id);
                if (user.id != null) {
                  context.read<UserProvider>().setUserId(user.id!);
                  context.go('/home');
                }
              },
              child: Text('Đăng nhập'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/register');
              },
              child: Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
