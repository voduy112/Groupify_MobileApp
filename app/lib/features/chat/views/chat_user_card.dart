import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ChatUserCard extends StatelessWidget{
    final User user;
    final String lastMsg;
    final VoidCallback onTap;

  const ChatUserCard({
    super.key,
    required this.user,
    required this.lastMsg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                  ? Text(
                      user.username![0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}