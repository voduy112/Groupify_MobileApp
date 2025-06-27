import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/document.dart';
import '../../../features/document_share/providers/document_share_provider.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../../../core/utils/validate.dart';
import '../../../core/widgets/custom_appbar.dart';

class EditDocumentScreen extends StatefulWidget {
  const EditDocumentScreen({super.key});

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? selectedImage;
  String? selectedFile;
  PlatformFile? imageFile;
  PlatformFile? mainFile;
  Document? doc;
  bool isUpdating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    doc = GoRouterState.of(context).extra as Document;
    _titleController = TextEditingController(text: doc?.title ?? '');
    _descriptionController =
        TextEditingController(text: doc?.description ?? '');
    selectedImage = doc?.imgDocument;
    selectedFile = doc?.mainFile;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = PlatformFile(
          name: pickedFile.name,
          path: pickedFile.path,
          size: File(pickedFile.path!).lengthSync(),
        );
        selectedImage = pickedFile.path;
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
        selectedFile = mainFile?.path;
      });
    }
  }

  Future<void> updateDocument() async {
    setState(() => isUpdating = true);
    final provider = context.read<DocumentShareProvider>();

    await provider.updateDocument(
      doc!.id!,
      Validate.normalizeText(_titleController.text),
      Validate.normalizeText(_descriptionController.text),
      imageFile,
      mainFile,
      userId: doc!.uploaderId,
    );

    if (mounted) {
      setState(() => isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật tài liệu thành công!')),
      );
      context.pop();
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
      appBar: const CustomAppBar(title: 'Cập nhật tài liệu'),
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
                  // Tiêu đề
                  CustomTextFormField(
                    label: 'Tiêu đề',
                    initialValue: _titleController.text,
                    onChanged: (value) {
                      final normalized = Validate.normalizeText(value);
                      _titleController.value = TextEditingValue(
                        text: normalized,
                        selection:
                            TextSelection.collapsed(offset: normalized.length),
                      );
                    },
                    onSaved: (value) => _titleController.text =
                        Validate.normalizeText(value ?? ''),
                    validator: (value) =>
                        Validate.notEmpty(value, fieldName: 'Tiêu đề'),
                  ),
                  const SizedBox(height: 20),

                  // Mô tả
                  CustomTextFormField(
                    label: 'Mô tả',
                    initialValue: _descriptionController.text,
                    maxLines: 3,
                    onChanged: (value) {
                      final normalized = Validate.normalizeText(value);
                      _descriptionController.value = TextEditingValue(
                        text: normalized,
                        selection:
                            TextSelection.collapsed(offset: normalized.length),
                      );
                    },
                    onSaved: (value) => _descriptionController.text =
                        Validate.normalizeText(value ?? ''),
                    validator: (value) =>
                        Validate.notEmpty(value, fieldName: 'Mô tả'),
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
                          imageFile?.name ??
                              (selectedImage != null &&
                                      selectedImage!.isNotEmpty
                                  ? 'Đã có ảnh'
                                  : 'Chưa chọn ảnh'),
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        (imageFile?.path ?? selectedImage)?.isNotEmpty == true
                            ? Hero(
                                tag: 'preview-image',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imageFile?.path != null
                                      ? Image.file(
                                          File(imageFile!.path!),
                                          key: ValueKey(imageFile!.path),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          selectedImage!,
                                          key: ValueKey(selectedImage),
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
                          mainFile?.name ??
                              (selectedFile != null && selectedFile!.isNotEmpty
                                  ? selectedFile!.split('/').last
                                  : 'Chưa chọn file'),
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: isUpdating
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                updateDocument();
                              }
                            },
                      icon: isUpdating
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
                        isUpdating ? 'Đang cập nhật...' : 'Cập nhật',
                      ),
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
