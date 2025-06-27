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

  Future<void> _handleJoinRequest(BuildContext context) async {
    final currentUser = context.read<AuthProvider>().user;
    final provider = context.read<GroupRequestProvider>();

    if (currentUser == null) {
      _showAlert("Thông báo", "Bạn cần đăng nhập để xin vào nhóm");
      return;
    }

    _showProcessingDialog("Đang gửi yêu cầu vào nhóm...");

    bool success = false;
    String errorMessage = "";
    try {
      success = await provider.sendRequest(widget.groupId, currentUser.id!);
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

    _showAlert(
      success ? "Thành công" : "Thất bại",
      success
          ? "Đã gửi yêu cầu vào nhóm thành công"
          : (errorMessage.contains("isExist")
              ? "Bạn đã gửi yêu cầu trước đó"
              : "Gửi yêu cầu vào nhóm thất bại"),
    );
  }

  void _showInviteCodeDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Nhập mã mời",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nhập mã..."),
            onSubmitted: (code) =>
                _handleJoinGroupByCode(code.trim(), contextDialog),
          ),
          actions: [
            TextButton(
              child: const Text("Đóng"),
              onPressed: () => Navigator.pop(contextDialog),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Nền xanh dương
                foregroundColor: Colors.white, // Chữ trắng
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Gửi"),
              onPressed: () =>
                  _handleJoinGroupByCode(controller.text.trim(), contextDialog),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleJoinGroupByCode(
      String code, BuildContext dialogContext) async {
    if (code.isEmpty || !mounted) return;

    Navigator.pop(dialogContext);

    final user = context.read<AuthProvider>().user;
    final groupProvider = context.read<GroupProvider>();

    if (user == null) {
      _showAlert("Thông báo", "Bạn cần đăng nhập để tham gia nhóm");
      return;
    }

    _showProcessingDialog("Đang tham gia nhóm...");

    bool success = false;
    String? errorMessage;
    try {
      success =
          await groupProvider.joinGroupByCode(widget.groupId, code, user.id!);
    } catch (e) {
      errorMessage = e.toString();
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GroupDetailScreenMember(groupId: widget.groupId),
        ),
      );
    } else {
      _showAlert(
          "Thất bại",
          groupProvider.error?.contains("đã tham gia") == true
              ? "Bạn đã ở trong nhóm này rồi"
              : groupProvider.error?.replaceFirst('Exception: ', '') ??
                  "Lỗi khi tham gia nhóm");
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  void _showProcessingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        title: const Text("Đang xử lý"),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  String formatDate(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 17, color: Colors.black),
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _group!.imgGroup != null
                      ? CachedNetworkImage(
                          imageUrl: _group!.imgGroup!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
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
                          _infoRow(Icons.person, "Trưởng nhóm", ownerName),
                          const SizedBox(height: 14),
                          _infoRow(Icons.group, "Thành viên",
                              "${_group!.membersID?.length ?? 0}"),
                          const SizedBox(height: 14),
                          _infoRow(Icons.date_range, "Ngày tạo",
                              formatDate(_group!.createDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_alt_1,
                              color: Colors.white),
                          label: const Text(
                            "Tham gia nhóm",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _handleJoinRequest(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          label: const Text(
                            "Mã mời",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showInviteCodeDialog(context),
                        ),
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
