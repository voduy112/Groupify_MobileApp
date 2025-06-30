import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/providers/auth_provider.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/utils/validate.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      setState(() => _isLoading = true);

      await authProvider.changePassword(
        authProvider.user?.email ?? '',
        oldPassword,
        newPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công, vui lòng đăng nhập lại.'),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      await authProvider.logout(context);
      if (mounted) context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _changePassword();
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                label: 'Mật khẩu cũ',
                fieldName: 'Mật khẩu cũ',
                obscureText: _obscureOld,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureOld = !_obscureOld);
                  },
                ),
                validator: Validate.notEmpty,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Mật khẩu mới',
                fieldName: 'Mật khẩu mới',
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureNew = !_obscureNew);
                  },
                ),
                validator: Validate.password,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Nhập lại mật khẩu mới',
                fieldName: 'Nhập lại mật khẩu mới',
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lại mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
