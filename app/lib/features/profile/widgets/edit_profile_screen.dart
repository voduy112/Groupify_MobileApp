import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../models/user.dart';
import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/custom_appbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phone;
  String? bio;

  File? _avatarImage;
  String? _avatarUrl;
  bool _isInitialized = false;
  User? _user;
  User? _userupdate;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = GoRouterState.of(context).extra;
      if (user != null && user is User) {
        _user = user;
        name = user.username ?? '';
        phone = user.phoneNumber ?? '';
        bio = user.bio ?? '';
        _avatarUrl = user.profilePicture;
      }
      _isInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUser() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    //Xóa khoảng trắng thừa
    final normalizedName = Validate.normalizeText(name ?? '');
    final normalizedPhone = Validate.normalizeText(phone ?? '');
    final normalizedBio = Validate.normalizeText(bio ?? '');

    _userupdate = User(
      id: _user!.id,
      username: normalizedName,
      phoneNumber: normalizedPhone,
      profilePicture: _avatarImage != null ? _avatarImage!.path : _avatarUrl,
      bio: normalizedBio,
      email: _user!.email,
      refreshToken: _user!.refreshToken,
      accessToken: _user!.accessToken,
      fcmToken: _user!.fcmToken,
    );

    await authProvider.updateUser(
      _user!.id!,
      _userupdate!,
      avatarImage: _avatarImage,
    );

    setState(() {
      _user = _userupdate;
      _avatarUrl = _userupdate!.profilePicture;
      _avatarImage = null;
      name = _userupdate!.username;
      phone = _userupdate!.phoneNumber;
      bio = _userupdate!.bio;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chỉnh sửa hồ sơ',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _updateUser();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu thông tin!')),
                        );
                        context.go('/profile');
                      }
                    }
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? NetworkImage(_avatarUrl!)
                          : const AssetImage('assets/avatar_placeholder.png')
                              as ImageProvider),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tên
              CustomTextFormField(
                label: 'Tên',
                initialValue: name,
                onSaved: (value) => name = value,
                validator: Validate.notEmpty,
              ),
              const SizedBox(height: 16),

              // SĐT
              CustomTextFormField(
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                initialValue: phone,
                onSaved: (value) => phone = value,
                validator: Validate.phone,
              ),
              const SizedBox(height: 16),

              // Bio
              CustomTextFormField(
                label: 'Bio',
                initialValue: bio,
                maxLines: 3,
                onSaved: (value) => bio = value,
                validator: Validate.notEmpty,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
