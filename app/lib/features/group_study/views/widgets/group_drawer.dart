import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../group_content_detail.dart';
import '../../../../models/group.dart';
import '../../providers/group_provider.dart';
import '../group_detail_screen_member.dart';
import '../group_study_screen.dart';

class GroupDrawer extends StatelessWidget {
  final VoidCallback onViewMembers;
  final VoidCallback onLeaveGroup;
  final String groupId;
  final VoidCallback onDeleteGroup;
  final Group group;
  final String currentUserId;
  final Future<bool> Function(String groupId, String newOwnerId) onChangeOwner;

  const GroupDrawer({
    Key? key,
    required this.groupId,
    required this.onViewMembers,
    required this.onLeaveGroup,
    required this.group,
    required this.currentUserId,
    required this.onDeleteGroup,
    required this.onChangeOwner,
  }) : super(key: key);

  void showChangeOwnerDialog(BuildContext context) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.fetchGroupMembers(groupId);

    final members = groupProvider.members
        .where((user) => user.id != currentUserId)
        .toList();

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không có thành viên nào để chuyển quyền')),
      );
      return;
    }

    String? selectedMemberId;

    // Lưu context ngoài (của Drawer)
    final outsideContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chuyển quyền trưởng nhóm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn thành viên để chuyển quyền trưởng nhóm:'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: null,
                hint: const Text("Chọn thành viên"),
                isExpanded: true,
                items: members.map((user) {
                  return DropdownMenuItem(
                    value: user.id,
                    child: Text(user.username!),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedMemberId = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedMemberId == null) {
                  ScaffoldMessenger.of(outsideContext).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn thành viên')),
                  );
                  return;
                }

                // Đóng dialog
                Navigator.pop(dialogContext);

                // Đóng Drawer
                Navigator.pop(outsideContext);

                final success = await onChangeOwner(groupId, selectedMemberId!);

                ScaffoldMessenger.of(outsideContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Chuyển quyền thành công'
                          : 'Chuyển quyền thất bại',
                    ),
                  ),
                );

                // 👉 Điều hướng đến DetailMemberScreen
                if (success) {
                  Navigator.push(
                    outsideContext,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupDetailScreenMember(groupId: groupId),
                    ),
                  );
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.ownerId['_id'] == currentUserId;

    return SizedBox(
      width: 250,
      child: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Tuỳ chọn',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 24, thickness: 1),

              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Xem thành viên'),
                onTap: onViewMembers,
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Xem chi tiết'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupContentDetail(
                        groupId: groupId,
                        currentUserId: currentUserId,
                      ),
                    ),
                  );
                },
              ),

              // Nếu là admin thì hiển thị nút chuyển quyền, ngược lại là rời nhóm
              isAdmin
                  ? ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text('Chuyển quyền trưởng nhóm'),
                      onTap: () => showChangeOwnerDialog(context),
                    )
                  : ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Rời nhóm'),
                      onTap: onLeaveGroup,
                    ),

              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Xóa nhóm'),
                  onTap: onDeleteGroup,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
