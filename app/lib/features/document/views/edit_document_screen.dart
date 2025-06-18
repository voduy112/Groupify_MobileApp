import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
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
        await provider.updateDocument(
          widget.document.id!,
          title,
          description,
          imageFile,
          mainFile,
          groupId: widget.document.groupId,
        );
        _showDialog("Thành công", "Cập nhật tài liệu thành công", onClose: () {
          context.pop(true);
        });
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
        title: Text('Chỉnh sửa tài liệu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tiêu đề
              CustomTextFormField(
                label: 'Tiêu đề',
                fieldName: 'Tiêu đề',
                initialValue: title,
                onSaved: (value) => title = value ?? '',
              ),
              SizedBox(height: 16),

              /// Mô tả
              CustomTextFormField(
                label: 'Mô tả',
                fieldName: 'Mô tả',
                initialValue: description,
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              SizedBox(height: 16),

              /// Chọn ảnh
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Chọn ảnh'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      imageFile?.name ??
                          (widget.document.imgDocument?.split('/').last ??
                              'Không có ảnh'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
                )
              else if (widget.document.imgDocument != null &&
                  widget.document.imgDocument!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.document.imgDocument!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),

              /// Chọn file PDF
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickMainFile,
                    child: Text('Chọn file tài liệu'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mainFile?.name ??
                          (widget.document.mainFile?.split('/').last ??
                              'Không có file'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              /// Nút cập nhật
              Center(
                child: Consumer<DocumentProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    onPressed: provider.isLoading ? null : updateDocument,
                    child: provider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Cập nhật'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
