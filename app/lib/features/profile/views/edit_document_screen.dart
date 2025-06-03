import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../features/document_share/providers/document_share_provider.dart';

class EditDocumentScreen extends StatefulWidget {
  const EditDocumentScreen({super.key});

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    setState(() {
      isUpdating = true;
    });
    final provider = Provider.of<DocumentShareProvider>(context, listen: false);
    await provider.updateDocument(
      doc!.id!,
      _titleController.text,
      _descriptionController.text,
      imageFile,
      mainFile,
      userId: doc!.uploaderId,
    );
    if (mounted) {
      setState(() {
        isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật tài liệu thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        leading: BackButton(),
      ),
      body: Container(
        color: const Color(0xFFF8F6D8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: const Text('Chọn ảnh'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      imageFile?.name ??
                          (selectedImage != null && selectedImage!.isNotEmpty
                              ? 'Đã có ảnh'
                              : 'Chưa chọn ảnh'),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if ((imageFile?.path ?? selectedImage)?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: (imageFile != null && imageFile!.path != null)
                          ? Image.file(
                              File(imageFile!.path!),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : (selectedImage != null && selectedImage!.isNotEmpty)
                              ? Image.network(
                                  selectedImage!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : SizedBox.shrink(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickMainFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: const Text('Chọn file tài liệu'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mainFile?.name ??
                          (selectedFile != null && selectedFile!.isNotEmpty
                              ? selectedFile!.split('/').last
                              : 'Chưa chọn file'),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: isUpdating
                      ? null // Disable button khi đang loading
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            updateDocument();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: isUpdating
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
                              const SizedBox(width: 12),
                              const Text('Đang cập nhật...'),
                            ],
                          )
                        : const Text('Cập nhật'),
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
