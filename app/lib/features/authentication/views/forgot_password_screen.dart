import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/authentication/views/otp_verification_screen.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../core/widgets/custom_appbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _otpVerified = false;
  bool _obscurePassword = true;

  void _goToOTPVerification() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final sent = await context.read<AuthProvider>().sendOTPEmail(email);

    if (!mounted) return;

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi OTP thất bại!')),
      );
      return;
    }

    // Chuyển sang màn hình nhập OTP và truyền onSuccess callback
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPVerificationScreen(
          email: email,
          onSuccess: () {
            if (!mounted) return;
            setState(() {
              _otpVerified = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xác thực OTP thành công!')),
            );
            Navigator.pop(context); // Quay về màn hình quên mật khẩu
          },
        ),
      ),
    );
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final success =
        await context.read<AuthProvider>().resetPassword(email, password);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công!')),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thất bại! Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle beautifulButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0072ff),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 4,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
    return Scaffold(
      appBar: CustomAppBar(title: 'Quên mật khẩu'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                enabled: !_otpVerified,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              if (!_otpVerified)
                ElevatedButton(
                  style: beautifulButtonStyle,
                  onPressed: _goToOTPVerification,
                  child: const Text('Gửi mã OTP'),
                ),
              if (_otpVerified) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: beautifulButtonStyle,
                  onPressed: _resetPassword,
                  child: const Text('Đổi mật khẩu'),
                ),
              ],
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Quay về đăng nhập',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
