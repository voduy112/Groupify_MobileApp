import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/group.dart';
import '../services/group_service.dart';
import '../../../features/document/providers/document_provider.dart';
import '../../../features/quiz/providers/quiz_provider.dart';
import '../providers/group_provider.dart';
import 'package:intl/intl.dart';

class GroupContentDetail extends StatefulWidget {
  final String groupId;
  final String currentUserId;

  const GroupContentDetail({
    Key? key,
    required this.groupId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<GroupContentDetail> createState() => _GroupContentDetailState();
}

class _GroupContentDetailState extends State<GroupContentDetail> {
  final GroupService _groupService = GroupService();

  Group? _group;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final group = await _groupService.getGroup(widget.groupId);

      final docProvider = Provider.of<DocumentProvider>(context, listen: false);
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      await Future.wait([
        docProvider.fetchCountByGroupId(widget.groupId),
        quizProvider.fetchCountByGroupId(widget.groupId),
      ]);

      if (!mounted) return;
      setState(() {
        _group = group;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatDate(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _group!.name);
    final descriptionController =
        TextEditingController(text: _group!.description);
    final subjectController = TextEditingController(text: _group!.subject);

    File? selectedImageFile;

    bool isSaving = false; // Đưa ra ngoài builder

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> saveGroup() async {
              setStateDialog(() {
                isSaving = true;
              });

              final groupProvider =
                  Provider.of<GroupProvider>(context, listen: false);
              final success = await groupProvider.updateGroup(
                groupId: widget.groupId,
                name: nameController.text,
                description: descriptionController.text,
                subject: subjectController.text,
                membersID: _group?.membersID ?? [],
                imageFile: selectedImageFile,
              );

              setStateDialog(() {
                isSaving = false;
              });

              if (success) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật nhóm thành công')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật nhóm thất bại')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: Colors.lightBlue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Center(
                child: Text(
                  'Chỉnh sửa nhóm',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              content: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            File? image = await pickImage();
                            if (image != null) {
                              setStateDialog(() {
                                selectedImageFile = image;
                              });
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundImage: selectedImageFile != null
                                    ? FileImage(selectedImageFile!)
                                    : (_group!.imgGroup != null
                                        ? NetworkImage(_group!.imgGroup!)
                                            as ImageProvider
                                        : const AssetImage(
                                            'assets/default_group.png')),
                              ),
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên nhóm',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Môn học',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSaving)
                    Positioned.fill(
                      child: Container(
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSaving ? null : saveGroup,
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text("Lỗi: $_error")),
      );
    }

    if (_group == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy thông tin nhóm")),
      );
    }

    String ownerId =
        _group?.ownerId is String ? _group!.ownerId : _group!.ownerId['_id'];

    String ownerName = _group?.ownerId is Map<String, dynamic>
        ? (_group!.ownerId['username'] ?? 'Không rõ người dùng')
        : 'Không rõ người dùng';

    final docCount = context.watch<DocumentProvider>().count;
    final quizCount = context.watch<QuizProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nhóm ' '${_group!.name!}'),
        actions: [
          if (ownerId == widget.currentUserId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_group!.imgGroup != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _group!.imgGroup!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Mô tả
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Mô tả: ${_group!.description ?? ''}",
                          style: const TextStyle(fontSize: 24),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chủ nhóm
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Chủ nhóm: $ownerName",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.group,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Thành viên: ${1 + (_group!.membersID?.length ?? 0)}",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Số tài liệu: $docCount",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.quiz,
                        color: Colors.lime,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Số bộ câu hỏi: $quizCount",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.cyan,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ngày tạo: ${formatDate(_group!.createDate)}",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
