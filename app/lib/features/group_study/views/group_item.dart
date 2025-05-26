import 'package:flutter/material.dart';
import '../../../models/group.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupItem extends StatelessWidget {
  final Group group;
  final VoidCallback? onTap;

  const GroupItem({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh nhóm
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  group.imgGroup!,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),

              const SizedBox(width: 12),
              // Thông tin nhóm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name ?? 'Tên nhóm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Môn: ${group.subject ?? 'Không xác định'}',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
