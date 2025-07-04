import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/group.dart';
import '../../../../models/user.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../chat/views/chat_screen.dart';
import '../../providers/group_provider.dart';

class MemberListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final Group group;

  const MemberListWidget({Key? key, required this.members, required this.group})
      : super(key: key);

  @override
  State<MemberListWidget> createState() => _MemberListWidgetState();
}

class _MemberListWidgetState extends State<MemberListWidget> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final ownerId = widget.group.ownerId is Map
        ? widget.group.ownerId['_id']
        : widget.group.ownerId;

    final isOwner = ownerId == currentUser.id;

    final members = widget.members.where((member) {
      final username = (member['username'] ?? '').toLowerCase();
      return username.contains(_searchQuery.toLowerCase());
    }).toList();

    if (members.isEmpty) {
      return const Center(child: Text('Không có thành viên nào trong nhóm.'));
    }

    return Container(
      color: Colors.white, // Nền trắng
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16), // padding nhỏ lại
                hintText: 'Tìm kiếm thành viên...',
                hintStyle: const TextStyle(fontSize: 14), // chữ nhỏ
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              style: const TextStyle(fontSize: 14), // chữ người dùng nhập nhỏ
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final username = member['username'] ?? '';
                final avatarUrl = member['profilePicture'] ?? '';
                final memberId = member['id'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: memberId == currentUser.id
                      ? Colors.grey[300]
                      : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      username,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: memberId == currentUser.id
                            ? Colors.grey[700]
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      memberId == ownerId ? 'Quản trị viên' : 'Thành viên',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            memberId == ownerId ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (memberId != currentUser.id)
                          IconButton(
                            icon: const Icon(Icons.chat,
                                color: Colors.blueGrey, size: 20),
                            onPressed: () {
                              final otherUser = User(
                                id: memberId,
                                username: username,
                                profilePicture: avatarUrl,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    currentUserId: currentUser.id!,
                                    otherUser: otherUser,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (memberId != currentUser.id && isOwner)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red, size: 22),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xoá thành viên'),
                                  content: Text(
                                      'Bạn có chắc muốn xoá "$username" khỏi nhóm?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Huỷ'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Xoá'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final success =
                                    await groupProvider.removeMember(
                                  widget.group.id!,
                                  memberId,
                                );

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Đã xoá thành viên.')),
                                  );
                                  setState(() {
                                    widget.members.removeWhere(
                                        (m) => m['id'] == memberId);
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Xoá thất bại: ${groupProvider.error ?? ''}')),
                                  );
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
