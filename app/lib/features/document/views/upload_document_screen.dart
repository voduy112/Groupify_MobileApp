import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../services/notification/messaging_provider.dart';

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = PlatformFile(
          name: pickedFile.name,
          path: pickedFile.path,
          size: 0,
        );
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

      final documentProvider =
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

        context.read<MessagingProvider>().sendGroupDocumentNotification(
              user?.username ?? "",
              widget.groupId,
              title ?? "",
            );
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
              Navigator.of(context).pop();
              if (onClose != null) onClose();
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
          onPressed: () => context.pop(),
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
              CustomTextFormField(
                label: 'Tiêu đề',
                fieldName: 'Tiêu đề',
                onSaved: (value) => title = value,
              ),
              SizedBox(height: 16),

              // Description
              CustomTextFormField(
                label: 'Mô tả',
                fieldName: 'Mô tả',
                maxLines: 3,
                onSaved: (value) => description = value,
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
                  Expanded(
                    child: Text(
                      imageFile?.name ?? 'Chưa chọn ảnh',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (imageFile?.path != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imageFile!.path!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                      onPressed: provider.isLoading ? null : uploadDocument,
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
