import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ChatUserCard extends StatelessWidget {
  final User user;
  final String lastMsg;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatUserCard({
    super.key,
    required this.user,
    required this.lastMsg,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(user.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text(
                'Bạn có chắc chắn muốn xóa cuộc trò chuyện này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: (user.profilePicture != null &&
                      user.profilePicture!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: user.profilePicture!,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 45,
                        height: 45,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _fallbackAvatar(user),
                    )
                  : _fallbackAvatar(user),
            ),
            title: Text(
              user.username ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              lastMsg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(User user) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.shade300,
      child: Text(
        user.username![0].toUpperCase(),
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
