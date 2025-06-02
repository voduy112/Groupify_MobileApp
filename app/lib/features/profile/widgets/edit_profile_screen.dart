import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../../../models/user.dart';
import '../../../core/utils/validate.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _avatarImage;
  String? _avatarUrl;
  bool _isInitialized = false;
  User? _user;
  User? _userupdate;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = GoRouterState.of(context).extra;
      if (user != null && user is User) {
        _user = user;
        _nameController.text = user.username ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _bioController.text = user.bio ?? '';
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
    _userupdate = User(
      id: _user!.id,
      username: _nameController.text,
      phoneNumber: _phoneController.text,
      profilePicture: _avatarImage != null ? _avatarImage!.path : _avatarUrl,
      bio: _bioController.text,
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
      _nameController.text = _userupdate!.username ?? '';
      _phoneController.text = _userupdate!.phoneNumber ?? '';
      _bioController.text = _userupdate!.bio ?? '';
    });
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
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
                      decoration: BoxDecoration(
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
                validator: Validate.notEmpty,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: Validate.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                validator: Validate.notEmpty,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await _updateUser();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đã lưu thông tin!')),
                            );
                            context.go('/profile');
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
