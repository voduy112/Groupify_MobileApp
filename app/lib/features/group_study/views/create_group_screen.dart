import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../../authentication/providers/auth_provider.dart';

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
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Nhóm Mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Tên nhóm', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập tên nhóm' : null,
                decoration: InputDecoration(isDense: true),
              ),
              SizedBox(height: 12),
              Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _subjectController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập môn học' : null,
                decoration: InputDecoration(isDense: true),
              ),
              SizedBox(height: 12),
              Text('Mã mời', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inviteCodeController,
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    tooltip: 'Tạo mã mới',
                    onPressed: () {
                      setState(() {
                        _inviteCodeController.text = _generateInviteCode();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _descriptionController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nhập mô tả' : null,
                maxLines: 3,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
              SizedBox(height: 12),
              if (_uploadedImageUrl != null) ...[
                Text('Ảnh nhóm đã tải lên',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Image.network(_uploadedImageUrl!, height: 150),
              ] else if (_selectedImage != null) ...[
                Text('Ảnh nhóm đã chọn',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Image.file(_selectedImage!, height: 150),
              ] else ...[
                Text('Tải ảnh lên',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Chọn ảnh nhóm'),
                onPressed: _pickImage,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Tạo nhóm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
