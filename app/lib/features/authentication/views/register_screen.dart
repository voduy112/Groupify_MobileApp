import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';
import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_text_form_field.dart';

enum EmailValidationState { pristine, checking, available, unavailable }

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  EmailValidationState _emailState = EmailValidationState.pristine;
  Timer? _debounce;

  void _checkEmail(String email) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (email.isEmpty || Validate.email(email) != null) {
      setState(() {
        _emailState = EmailValidationState.pristine;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      setState(() {
        _emailState = EmailValidationState.checking;
      });
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.checkEmail(email);
      setState(() {
        if (result.toLowerCase().contains('email chưa tồn tại')) {
          _emailState = EmailValidationState.available;
        } else {
          _emailState = EmailValidationState.unavailable;
        }
        _emailFieldKey.currentState?.validate();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Widget? _buildEmailSuffixIcon() {
    switch (_emailState) {
      case EmailValidationState.checking:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case EmailValidationState.available:
        return const Icon(Icons.check, color: Colors.green);
      case EmailValidationState.unavailable:
        return const Icon(Icons.error, color: Colors.red);
      case EmailValidationState.pristine:
        return const Icon(Icons.email_outlined, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Đăng ký', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Họ và tên',
                  fieldName: 'Họ và tên',
                  validator: Validate.notEmpty,
                  onSaved: (val) => nameController.text = val ?? '',
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  key: _emailFieldKey,
                  label: 'Email',
                  fieldName: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _checkEmail,
                  validator: (value) {
                    final emailError = Validate.email(value);
                    if (emailError != null) {
                      return emailError;
                    }
                    if (_emailState == EmailValidationState.unavailable) {
                      return 'Email đã tồn tại';
                    }
                    return null;
                  },
                  onSaved: (val) => emailController.text = val ?? '',
                  suffixIcon: _buildEmailSuffixIcon(),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: 'Số điện thoại',
                  fieldName: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                  validator: Validate.phone,
                  onSaved: (val) => phoneController.text = val ?? '',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
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
                  ),
                  validator: Validate.password,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Nhập lại mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu';
                    }
                    if (value != passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 10),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => isLoading = true);

                            final success =
                                await context.read<AuthProvider>().register(
                                      nameController.text,
                                      emailController.text,
                                      phoneController.text,
                                      passwordController.text,
                                    );

                            setState(() => isLoading = false);

                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OTPVerificationScreen(
                                      email: emailController.text),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng ký thất bại!'),
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Đăng ký',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Đã có tài khoản? Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
