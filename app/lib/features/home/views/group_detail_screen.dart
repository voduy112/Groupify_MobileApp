import 'package:flutter/material.dart';
import '../../../models/group.dart';
import '../../group_study/services/group_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  Group? _group;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroupDetail();
  }

  Future<void> _loadGroupDetail() async {
    try {
      final group = await _groupService.getGroup(widget.groupId);
      setState(() {
        _group = group;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
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

    final from = GoRouterState.of(context).extra is Map
        ? (GoRouterState.of(context).extra as Map)['from']
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.name ?? "Chi tiết nhóm"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (from == 'show_all_group') {
              context.go('/home/show-all-group');
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_group?.imgGroup != null)
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
                  Text(
                    _group?.name ?? "Không tên",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _group?.description ?? "Không có mô tả",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.subject),
                      const SizedBox(width: 8),
                      Text("Môn: ${_group?.subject ?? 'Không rõ'}"),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 8),
                      Text("Chủ nhóm: ${_group?.ownerId ?? 'Không rõ'}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group),
                      const SizedBox(width: 8),
                      Text("Thành viên: ${_group?.membersID?.length ?? 0}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text("Ngày tạo: ${formatDate(_group?.createDate)}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Xin vào nhóm"),
                    onPressed: () {
                      // TODO: Logic xin vào nhóm
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Đang xử lý xin vào nhóm...")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Mã mời"),
                    onPressed: () {
                      // TODO: Logic xử lý mã mời
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Nhập mã mời"),
                            content: TextField(
                              decoration:
                                  const InputDecoration(hintText: "Nhập mã..."),
                              onSubmitted: (code) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Đã nhập mã: $code")),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Đóng"),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
