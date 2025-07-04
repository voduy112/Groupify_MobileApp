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
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();

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
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _emailFieldKey.currentState?.validate();
      }
    });

    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        _phoneFieldKey.currentState?.validate();
      }
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-right pink circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0072ff),
                    Color.fromARGB(255, 92, 184, 241)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Bottom pink curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0072ff),
                    Color.fromARGB(255, 92, 184, 241)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đăng kí',
                      style: TextStyle(
                        color: Color(0xFF0072ff),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Chào bạn! Đăng kí tài khoản ngay",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    CustomTextFormField(
                      label: 'Họ và tên',
                      fieldName: 'Họ và tên',
                      validator: Validate.notEmpty,
                      onSaved: (val) => nameController.text = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      key: _emailFieldKey,
                      focusNode: _emailFocusNode,
                      label: 'Email',
                      fieldName: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _checkEmail,
                      validator: (value) {
                        final normalized = Validate.normalizeText(value ?? '');

                        final emptyError =
                            Validate.notEmpty(normalized, fieldName: 'Email');
                        if (emptyError != null) return emptyError;

                        if (!_emailFocusNode.hasFocus &&
                            Validate.email(normalized) != null) {
                          return 'Email không hợp lệ';
                        }

                        if (_emailState == EmailValidationState.unavailable) {
                          return 'Email đã tồn tại';
                        }

                        return null;
                      },
                      onSaved: (val) => emailController.text = val ?? '',
                      suffixIcon: _buildEmailSuffixIcon(),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      key: _phoneFieldKey,
                      focusNode: _phoneFocusNode,
                      label: 'Số điện thoại',
                      fieldName: 'Số điện thoại',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final normalized = Validate.normalizeText(value ?? '');

                        final emptyError = Validate.notEmpty(normalized,
                            fieldName: 'Số điện thoại');
                        if (emptyError != null) return emptyError;

                        if (!_phoneFocusNode.hasFocus &&
                            Validate.phone(normalized) != null) {
                          return 'Số điện thoại không hợp lệ';
                        }

                        return null;
                      },
                      onSaved: (val) => phoneController.text = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      label: 'Mật khẩu',
                      fieldName: 'Mật khẩu',
                      obscureText: _obscurePassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: Validate.password,
                      onSaved: (val) => passwordController.text = val ?? '',
                      onChanged: (val) => passwordController.text = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      label: 'Nhập lại mật khẩu',
                      fieldName: 'Nhập lại mật khẩu',
                      obscureText: _obscureConfirmPassword,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập lại mật khẩu';
                        }
                        if (Validate.normalizeText(value) !=
                            Validate.normalizeText(passwordController.text)) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                      onSaved: (val) =>
                          confirmPasswordController.text = val ?? '',
                      onChanged: (val) =>
                          confirmPasswordController.text = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (_) {},
                        ),
                        const Expanded(
                          child: Text(
                            'Tôi đồng ý với các điều khoản',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0072ff),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
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
                                      builder: (context) =>
                                          OTPVerificationScreen(
                                        email: emailController.text,
                                        onSuccess: () {
                                          context.go('/login');
                                        },
                                      ),
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
                          ? const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)
                          : const Text(
                              'Đăng kí',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text.rich(
                        TextSpan(
                          text: "Bạn đã có tài khoản. ",
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Đăng nhập",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
