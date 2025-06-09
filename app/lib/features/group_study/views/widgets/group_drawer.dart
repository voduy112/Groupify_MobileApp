import 'package:flutter/material.dart';

import '../../../../models/group.dart';

class GroupDrawer extends StatelessWidget {
  final VoidCallback onViewMembers;
  final VoidCallback onLeaveGroup;
  final VoidCallback onDeleteGroup;
  final Group group;
  final String currentUserId;

  const GroupDrawer({
    Key? key,
    required this.onViewMembers,
    required this.onLeaveGroup,
    required this.group,
    required this.currentUserId,
    required this.onDeleteGroup,
  }) : super(key: key);

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

              // Danh sách chức năng
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Xem thành viên'),
                onTap: onViewMembers,
              ),
              if (!isAdmin)
                ListTile(
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
