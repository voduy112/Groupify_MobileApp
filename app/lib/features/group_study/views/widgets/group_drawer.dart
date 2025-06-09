import 'package:flutter/material.dart';

class GroupDrawer extends StatelessWidget {
  final VoidCallback onViewMembers;
  final VoidCallback onLeaveGroup;

  const GroupDrawer({
    Key? key,
    required this.onViewMembers,
    required this.onLeaveGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Rời nhóm'),
                onTap: onLeaveGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
