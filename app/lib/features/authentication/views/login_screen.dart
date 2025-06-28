import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../features/authentication/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              // Sóng xanh (dưới)
              ClipPath(
                clipper: TopWaveClipper2(),
                child: Container(
                  height: 270,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFB3E5FC),
                        Color(0xFF81D4FA),
                        Color.fromARGB(255, 202, 132, 240),
                        Color.fromARGB(255, 142, 75, 177)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Sóng tím (trên cùng, cao hơn nhưng ít cao hơn)
              ClipPath(
                clipper: TopWaveClipper1(),
                child: Container(
                  height: 250, // nhỏ hơn để không che hết lớp dưới
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0083B0),
                        Color(0xFF00B4DB),
                        Color.fromARGB(255, 113, 202, 243),
                        Color.fromARGB(255, 143, 201, 228),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Logo và tên app
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/image/icon_app.png',
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GROUPIFY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // canh giữa dọc
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF0083B0),
                          Color(0xFF00B4DB),
                          Color.fromARGB(255, 113, 202, 243),
                          Color.fromARGB(255, 143, 201, 228),
                          Color(0xFF0083B0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: Text(
                        'Chào mừng trở lại!',
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      label: 'Email',
                      fieldName: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validate.email,
                      onSaved: (value) => _email = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: _obscurePassword,
                      style: textTheme.bodySmall?.copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        labelText: 'Mật khẩu',
                        labelStyle:
                            textTheme.labelLarge?.copyWith(fontSize: 15),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      validator: Validate.password,
                      onSaved: (value) => _password = value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Nhớ tôi',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: Color(0xFF0083B0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _handleLogin,
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  )
                                : const Center(
                                    child: Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Bạn chưa có tài khoản? Đăng ký',
                        style: TextStyle(
                          color: Color(0xFF0083B0),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 32, color: Color(0xFF0083B0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      final error = await authProvider.login(
        _email ?? '',
        _password ?? '',
        context,
      );
      final user = authProvider.user;

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null && user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.go('/home');
      } else if (error != null &&
          error.toString().contains('Vui lòng xác thực email')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng xác thực email của bạn'),
          ),
        );
        context.go('/otp-verify', extra: _email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Đăng nhập thất bại!'),
          ),
        );
      }
    }
  }
}

class TopWaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.57, // làm control thấp xuống
        size.width * 0.5,
        size.height * 0.70); // giữ đỉnh trung bình
    path.quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.83, // làm điểm gập ít dốc hơn
        size.width,
        size.height * 0.61); // kết thúc thấp hơn
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TopWaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.62, // nhẹ hơn
        size.width * 0.5,
        size.height * 0.75); // mềm ở giữa
    path.quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9, // giảm độ cong
        size.width,
        size.height * 0.5); // kết thúc cao hơn
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
