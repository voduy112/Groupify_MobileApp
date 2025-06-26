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
import '../../../core/widgets/custom_text_form_field.dart';
import 'package:flutter/services.dart';

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
    final formKey = GlobalKey<FormState>();
    final name = _group!.name ?? '';
    final description = _group!.description ?? '';
    final subject = _group!.subject ?? '';

    File? selectedImageFile;
    bool isSaving = false;

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String? nameVal, descriptionVal, subjectVal;

            Future<void> saveGroup() async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();

              setStateDialog(() {
                isSaving = true;
              });

              final groupProvider =
                  Provider.of<GroupProvider>(context, listen: false);
              final success = await groupProvider.updateGroup(
                groupId: widget.groupId,
                name: nameVal!,
                description: descriptionVal!,
                subject: subjectVal!,
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Center(
                child: Text(
                  'Chỉnh sửa nhóm',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
              content: Stack(
                children: [
                  SingleChildScrollView(
                    child: Form(
                      key: formKey,
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
                                  width: 112,
                                  height: 112,
                                  decoration: const BoxDecoration(
                                    color: Colors.black26,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tên nhóm
                          CustomTextFormField(
                            label: 'Tên nhóm',
                            initialValue: name,
                            fieldName: 'Tên nhóm',
                            onSaved: (value) => nameVal = value,
                          ),
                          const SizedBox(height: 16),

                          // Môn học
                          CustomTextFormField(
                            label: 'Môn học',
                            initialValue: subject,
                            fieldName: 'Môn học',
                            onSaved: (value) => subjectVal = value,
                          ),
                          const SizedBox(height: 16),

                          // Mô tả
                          CustomTextFormField(
                            label: 'Mô tả',
                            initialValue: description,
                            fieldName: 'Mô tả',
                            onSaved: (value) => descriptionVal = value,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isSaving)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent)),
                      ),
                    ),
                ],
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : saveGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22), // tăng size icon
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 17, color: Colors.black), // tăng size chữ
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inviteCodeRow(String label, String code) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.code, color: Colors.blueAccent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 17, color: Colors.black), // tăng size chữ
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: code),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
          tooltip: "Sao chép mã",
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã sao chép mã mời")),
              );
            }
          },
        ),
      ],
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      _group!.imgGroup != null && _group!.imgGroup!.isNotEmpty
                          ? Image.network(
                              _group!.imgGroup!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.blueAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  if (ownerId == widget.currentUserId)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: _showEditDialog,
                        ),
                      ),
                    ),
                ],
              ),
              SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _group!.name ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(Icons.description_outlined, "Mô tả",
                              _group!.description ?? ''),
                          const SizedBox(height: 14),
                          _infoRow(Icons.person, "Chủ nhóm", ownerName),
                          const SizedBox(height: 7),
                          _inviteCodeRow("Mã mời", _group!.inviteCode!),
                          const SizedBox(height: 7),
                          _infoRow(Icons.group, "Thành viên",
                              "${1 + (_group!.membersID?.length ?? 0)}"),
                          const SizedBox(height: 14),
                          _infoRow(
                              Icons.description, "Số tài liệu", "$docCount"),
                          const SizedBox(height: 14),
                          _infoRow(Icons.quiz, "Số bộ câu hỏi", "$quizCount"),
                          const SizedBox(height: 14),
                          _infoRow(Icons.date_range, "Ngày tạo",
                              formatDate(_group!.createDate)),
                        ],
                      ),
                    ),
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
