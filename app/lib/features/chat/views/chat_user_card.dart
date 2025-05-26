import 'package:cached_network_image/cached_network_image.dart';
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
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Màu bóng nhẹ
              blurRadius: 8, // Độ mờ bóng
              offset: const Offset(0, 4), // Tọa độ bóng
            ),
          ],
          borderRadius: BorderRadius.circular(12), // Bo góc thẻ cho mềm mại
        ),
        child: Row(
          children: [
            ClipOval(
              child: (user.profilePicture != null &&
                      user.profilePicture!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: user.profilePicture!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.username![0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        user.username![0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
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