import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../features/authentication/providers/user_provider.dart';
import '../../../features/home/views/home_screen.dart';
import '../../../core/widgets/main_scaffold.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validate.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Đăng nhập',
                    style: Theme.of(context).textTheme.titleLarge),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: Validate.email,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                  validator: Validate.password,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final authProvider = context.read<AuthProvider>();
                      final error = await authProvider.login(
                        emailController.text,
                        passwordController.text,
                      );
                      final user = authProvider.user;
                      if (error == null && user != null) {
                        context.go('/home');
                      } else if (error != null &&
                          error
                              .toString()
                              .contains('Please verify your email')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vui lòng xác thực email của bạn'),
                          ),
                        );
                        context.go('/otp-verify', extra: emailController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đăng nhập thất bại!')),
                        );
                      }
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
        ),
      ),
    );
  }
}
