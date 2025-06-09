import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/group.dart';
import '../../../../models/user.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../chat/views/chat_screen.dart';

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

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final members = widget.members.where((member) {
      final username = (member['username'] ?? '').toLowerCase();
      return username.contains(_searchQuery.toLowerCase());
    }).toList();

    if (members.isEmpty) {
      return const Center(child: Text('Không có thành viên nào trong nhóm.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thành viên...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
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
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: memberId == currentUser.id ? Colors.grey[300] : null,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: memberId == currentUser.id
                          ? Colors.grey[700]
                          : Colors.black,
                    ),
                  ),
                  trailing: memberId != currentUser.id
                      ? const Icon(Icons.chat, color: Colors.blueGrey)
                      : null,
                  onTap: () {
                    if (memberId == currentUser.id) return;

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
              );
            },
          ),
        ),
      ],
    );
  }
}
