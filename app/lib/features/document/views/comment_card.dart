import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/document_provider.dart';

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String currentUserId;
  final Future<bool> Function()? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DocumentProvider>(context);

    final username = comment['username'] ?? '';
    final avatarUrl = comment['avatar'];
    final rating = comment['rating']?.toDouble() ?? 0;
    final content = comment['content'] ?? '';
    final createdAt = comment['createdAt'] != null
        ? DateTime.tryParse(comment['createdAt'])?.toLocal()
        : null;
    final userId = comment['userId'];

    final timeDisplay = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
        : '';

    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.black),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleSmall,
                    children: [
                      TextSpan(text: username),
                      if (provider.currentUserId == comment['userId']) ...[
                        const TextSpan(
                          text: ' · ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const TextSpan(
                          text: 'Bạn',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                if (rating > 0)
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(content),
                if (timeDisplay.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      timeDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // Nếu là chủ comment thì cho phép swipe để xóa
    if (onDelete != null && currentUserId == userId) {
      return Dismissible(
        key: ValueKey(comment['_id']),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Xác nhận xoá'),
              content: const Text('Bạn có chắc chắn muốn xoá bình luận này?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Huỷ'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red.shade100),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.red.shade800),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Colors.red.shade800),
                    ),
                  ),
                  child: const Text('Xoá'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) async {
          final success = await onDelete?.call();
          if (!success! && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xoá bình luận thất bại')),
            );
          }
        },
        child: card,
      );
    } else {
      return card;
    }
  }
}
