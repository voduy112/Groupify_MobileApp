import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../group_study/providers/group_provider.dart';
import '../../../core/utils/validate.dart';

class UploadDocumentScreen extends StatefulWidget {
  final String groupId;

  const UploadDocumentScreen({super.key, required this.groupId});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  PlatformFile? imageFile;
  PlatformFile? mainFile;

  Future<void> _pickImage() async {
    print('Avatar tapped');
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    print('pickedFile: $pickedFile');
    if (pickedFile != null) {
      setState(() {
        imageFile = PlatformFile(
          name: pickedFile.name,
          path: pickedFile.path,
          size: 0,
        );
        print("imageFile: ${imageFile?.path}");
      });
    }
  }

  Future<void> pickMainFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        mainFile = result.files.first;
      });
    }
  }

  Future<void> uploadDocument() async {
    final user = context.read<AuthProvider>().user;

    if (imageFile?.path == null || imageFile!.path!.isEmpty) {
      _showDialog("Lỗi", "Vui lòng chọn ảnh");
      return;
    }

    if (mainFile?.path == null || mainFile!.path!.isEmpty) {
      _showDialog("Lỗi", "Vui lòng chọn file tài liệu PDF");
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DocumentProvider documentProvider =
          Provider.of<DocumentProvider>(context, listen: false);

      bool success = await documentProvider.uploadDocument(
        title: title!,
        description: description!,
        uploaderId: user?.id ?? "",
        imageFile: imageFile,
        mainFile: mainFile,
        groupId: widget.groupId,
      );

      if (success) {
        _showDialog("Thành công", "Tải tài liệu thành công", onClose: () {
          context.pop(true);
        });
      } else {
        _showDialog("Thất bại", "Tải tài liệu thất bại");
      }
    }
  }

  void _showDialog(String title, String content, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              if (onClose != null) onClose(); // Thực thi callback nếu có
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Upload Document'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                onSaved: (value) => title = value,
                validator: (value) => Validate.notEmpty(value),
              ),
              SizedBox(height: 16),
              // Description
              TextFormField(
                decoration: InputDecoration(labelText: 'Mô tả'),
                onSaved: (value) => description = value,
                validator: (value) => Validate.notEmpty(value),
              ),
              SizedBox(height: 16),
              // Image picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Chọn ảnh'),
                  ),
                  SizedBox(width: 8),
                  Text(
                    imageFile?.name ?? 'Chưa chọn ảnh',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Main file picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickMainFile,
                    child: Text('Chọn file tài liệu'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mainFile?.name ?? 'Chưa chọn file',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              // Submit button
              Center(
                child: Consumer<DocumentProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                uploadDocument();
                              }
                            },
                      child: provider.isLoading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Đang upload...'),
                              ],
                            )
                          : Text('Upload'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
