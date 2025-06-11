import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/group.dart';
import '../services/group_service.dart';
import 'package:intl/intl.dart';
import '../../../features/document/providers/document_provider.dart';
import '../../../features/quiz/providers/quiz_provider.dart';

class GroupContentDetail extends StatefulWidget {
  final String groupId;

  const GroupContentDetail({Key? key, required this.groupId}) : super(key: key);

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

    String ownerName = 'Không rõ người dùng';
    if (_group?.ownerId != null && _group!.ownerId is Map<String, dynamic>) {
      ownerName = _group!.ownerId['username'] ?? 'Không rõ người dùng';
    }

    final docCount = context.watch<DocumentProvider>().count;
    final quizCount = context.watch<QuizProvider>().count;

    return Scaffold(
      appBar: AppBar(title: Text('Nhóm ' '${_group!.name!}')),
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

                  // Thành viên
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

                  // Số tài liệu
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

                  // Số bộ câu hỏi
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

                  // Ngày tạo
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
