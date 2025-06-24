import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../models/group.dart';
import '../services/group_service.dart';
import 'package:intl/intl.dart';
import '../../grouprequest/providers/grouprequest_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../group_study/providers/group_provider.dart';
import './group_detail_screen_member.dart';
import '../../../services/notification/messaging_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

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

  Future<void> _handleJoinGroupByCode(
      String code, BuildContext dialogContext) async {
    if (code.isEmpty || !mounted) return;

    Navigator.pop(dialogContext);

    final user = context.read<AuthProvider>().user;
    final groupProvider = context.read<GroupProvider>();

    if (user == null) {
      if (!mounted) return;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => const AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          title: Text("Thông báo"),
          content: Text("Bạn cần đăng nhập để tham gia nhóm"),
        ),
      );
      return;
    }

    // Hiển thị dialog đang xử lý
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        title: Text("Đang xử lý"),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Đang tham gia nhóm..."),
          ],
        ),
      ),
    );

    bool success = false;
    String? errorMessage;
    try {
      success = await groupProvider.joinGroupByCode(
        widget.groupId,
        code,
        user.id!,
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      // Điều hướng đến màn hình GroupDetailScreenMember
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GroupDetailScreenMember(groupId: widget.groupId),
        ),
      );
    } else {
      // Hiển thị thông báo lỗi
      if (!mounted) return;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          title: const Text("Thất bại"),
          content: Text(groupProvider.error?.contains("đã tham gia") == true
              ? "Bạn đã ở trong nhóm này rồi"
              : groupProvider.error?.replaceFirst('Exception: ', '') ??
                  "Lỗi khi tham gia nhóm"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
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

    return Scaffold(
      appBar: AppBar(title: Text('Nhóm ' '${_group!.name!}')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_group!.imgGroup != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _group!.imgGroup!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
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
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Trưởng nhóm: $ownerName",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.group,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Thành viên: ${_group!.membersID?.length ?? 0}",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ngày tạo: ${formatDate(_group!.createDate)}",
                        style: TextStyle(fontSize: 24),
                      ),
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
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.blue,
                    ),
                    label: const Text("Tham gia nhóm"),
                    onPressed: () async {
                      final currentUser = context.read<AuthProvider>().user;
                      final provider = context.read<GroupRequestProvider>();

                      if (currentUser == null) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            title: const Text("Thông báo"),
                            content:
                                const Text("Bạn cần đăng nhập để xin vào nhóm"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Đóng"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          title: Text("Đang xử lý"),
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text("Đang gửi yêu cầu vào nhóm..."),
                            ],
                          ),
                        ),
                      );

                      bool success = false;
                      String errorMessage = "";
                      try {
                        success = await provider.sendRequest(
                            widget.groupId, currentUser.id!);
                        MessagingProvider().sendJoinRequestNotification(
                            _group!.ownerId!['fcmToken']!,
                            currentUser.username!,
                            _group!.name!,
                            _group!.id!,
                            currentUser.id!);
                      } catch (e) {
                        errorMessage = e.toString();
                      }

                      if (!mounted) return;
                      Navigator.of(context, rootNavigator: true).pop();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          title: Text(success ? "Thành công" : "Thất bại"),
                          content: Text(success
                              ? "Đã gửi yêu cầu vào nhóm thành công"
                              : (errorMessage.contains("isExist")
                                  ? "Bạn đã gửi yêu cầu trước đó"
                                  : "Gửi yêu cầu vào nhóm thất bại")),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(),
                              child: const Text("Đóng"),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.qr_code,
                      color: Colors.blue,
                    ),
                    label: const Text("Mã mời"),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (contextDialog) {
                          final TextEditingController controller =
                              TextEditingController();
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            title: const Text("Nhập mã mời"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Nhập mã...",
                              ),
                              onSubmitted: (code) => _handleJoinGroupByCode(
                                  code.trim(), contextDialog),
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Đóng"),
                                onPressed: () => Navigator.pop(contextDialog),
                              ),
                              ElevatedButton(
                                child: const Text("Gửi"),
                                onPressed: () => _handleJoinGroupByCode(
                                    controller.text.trim(), contextDialog),
                              ),
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
