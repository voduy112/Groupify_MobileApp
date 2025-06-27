import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../models/document.dart';

class EditDocumentScreen extends StatefulWidget {
  final Document document;

  const EditDocumentScreen({super.key, required this.document});

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  PlatformFile? imageFile;
  PlatformFile? mainFile;

  @override
  void initState() {
    super.initState();
    title = widget.document.title ?? '';
    description = widget.document.description ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = PlatformFile(
          name: pickedFile.name,
          path: pickedFile.path,
          size: File(pickedFile.path).lengthSync(),
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

  Future<void> updateDocument() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<DocumentProvider>();

      try {
        final success = await provider.updateDocument(
          widget.document.id!,
          title,
          description,
          imageFile,
          mainFile,
          groupId: widget.document.groupId,
        );

        if (success) {
          _showDialog("Thành công", "Cập nhật tài liệu thành công",
              onClose: () {
            context.pop(true);
          });
        } else {
          _showDialog("Thất bại", "Không thể cập nhật tài liệu.");
        }
      } catch (e) {
        _showDialog("Thất bại", "Cập nhật tài liệu thất bại");
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

    final beautifulButtonStyle = ElevatedButton.styleFrom(
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
      appBar: const CustomAppBar(title: 'Chỉnh sửa tài liệu'),
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
                  // Tiêu đề
                  CustomTextFormField(
                    label: 'Tiêu đề',
                    fieldName: 'Tiêu đề',
                    initialValue: title,
                    onSaved: (value) => title = value ?? '',
                  ),
                  const SizedBox(height: 20),

                  // Mô tả
                  CustomTextFormField(
                    label: 'Mô tả',
                    fieldName: 'Mô tả',
                    initialValue: description,
                    maxLines: 3,
                    onSaved: (value) => description = value ?? '',
                  ),
                  const SizedBox(height: 24),

                  // Chọn ảnh
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
                          imageFile?.name ??
                              (widget.document.imgDocument?.split('/').last ??
                                  'Không có ảnh'),
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
                        : (widget.document.imgDocument != null &&
                                widget.document.imgDocument!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.document.imgDocument!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Chọn file PDF
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
                          mainFile?.name ??
                              (widget.document.mainFile?.split('/').last ??
                                  'Không có file'),
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Nút cập nhật
                  Center(
                    child: Consumer<DocumentProvider>(
                      builder: (context, provider, _) => ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : updateDocument,
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          provider.isLoading ? 'Đang cập nhật...' : 'Cập nhật',
                        ),
                        style: beautifulButtonStyle,
                      ),
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
