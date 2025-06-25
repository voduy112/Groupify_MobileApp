import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/custom_appbar.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool _isSubmitting = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _inviteCodeController.text = _generateInviteCode();
  }

  String _generateInviteCode({int length = 8}) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(now + index) % chars.length])
        .join();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Vui lòng chọn ảnh nhóm')));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadedImageUrl = null;
    });

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final ownerId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    if (ownerId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không tìm thấy người dùng')));
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await groupProvider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _subjectController.text.trim(),
      inviteCode: _inviteCodeController.text.trim(),
      ownerId: ownerId,
      imageFile: _selectedImage!,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      final newGroup = groupProvider.groups.last;
      setState(() {
        _uploadedImageUrl = newGroup.imgGroup;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Tạo nhóm thành công')));
      Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(groupProvider.error ?? 'Tạo nhóm thất bại')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: CustomAppBar(title: "Tạo nhóm mới"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    label: 'Tên nhóm',
                    fieldName: 'Tên nhóm',
                    initialValue: _nameController.text,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập tên nhóm'
                        : null,
                    onSaved: (value) => _nameController.text = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    label: 'Môn học',
                    fieldName: 'Môn học',
                    initialValue: _subjectController.text,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập môn học'
                        : null,
                    onSaved: (value) => _subjectController.text = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  Text('Mã mời',
                      style: textTheme.titleSmall?.copyWith(fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _inviteCodeController,
                          readOnly: true,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        tooltip: 'Tạo mã mới',
                        onPressed: () {
                          setState(() {
                            _inviteCodeController.text = _generateInviteCode();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    label: 'Mô tả',
                    fieldName: 'Mô tả',
                    initialValue: _descriptionController.text,
                    maxLines: 3,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập mô tả'
                        : null,
                    onSaved: (value) =>
                        _descriptionController.text = value ?? '',
                  ),
                  const SizedBox(height: 24),
                  Text('Ảnh nhóm',
                      style: textTheme.titleSmall?.copyWith(fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_uploadedImageUrl != null)
                    Image.network(_uploadedImageUrl!, height: 150)
                  else if (_selectedImage != null)
                    Image.file(_selectedImage!, height: 150)
                  else
                    const Text(
                      'Chưa chọn ảnh',
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined, size: 20),
                    label: const Text('Chọn ảnh nhóm'),
                    style: beautifulButtonStyle,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.group_add_rounded),
                      label: Text(_isSubmitting ? 'Đang tạo...' : 'Tạo nhóm'),
                      style: beautifulButtonStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
