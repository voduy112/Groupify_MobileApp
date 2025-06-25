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
import '../../../core/widgets/custom_appbar.dart';

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
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onClose != null) onClose();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
      appBar: const CustomAppBar(title: 'Tải tài liệu lên'),
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextFormField(
                    label: 'Tiêu đề',
                    fieldName: 'Tiêu đề',
                    onSaved: (value) => title = value,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  CustomTextFormField(
                    label: 'Mô tả',
                    fieldName: 'Mô tả',
                    maxLines: 3,
                    onSaved: (value) => description = value,
                  ),
                  const SizedBox(height: 24),

                  // Image Picker
                  Text(
                    'Ảnh minh họa',
                    style: textTheme.titleSmall?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined, size: 20),
                        label: const Text('Chọn ảnh'),
                        style: beautifulButtonStyle,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          imageFile?.name ?? 'Chưa chọn ảnh',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeIn,
                    child: imageFile?.path != null
                        ? Hero(
                            tag: 'preview-image',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imageFile!.path!),
                                key: ValueKey(imageFile!.path),
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // File Picker
                  Text(
                    'File tài liệu (.pdf)',
                    style: textTheme.titleSmall?.copyWith(fontSize: 15),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: pickMainFile,
                        icon: const Icon(Icons.upload_file_rounded, size: 20),
                        label: const Text('Chọn file'),
                        style: beautifulButtonStyle,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          mainFile?.name ?? 'Chưa chọn file',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  Center(
                    child: Consumer<DocumentProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : uploadDocument,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_rounded),
                          label: Text(
                            provider.isLoading ? 'Đang upload...' : 'Tải lên',
                          ),
                          style: beautifulButtonStyle,
                        );
                      },
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
