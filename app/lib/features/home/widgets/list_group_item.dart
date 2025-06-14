import 'package:flutter/material.dart';

class ListGroupItem extends StatelessWidget {
  const ListGroupItem({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu group giả
    final groups = [
      {
        'title': 'Title group',
        'subject': 'An toàn hệ thống',
        'memberCount': 20,
        'imgGroup': null, // hoặc link ảnh nếu có
      },
      {
        'title': 'Title group',
        'subject': 'Anh Văn',
        'memberCount': 25,
        'imgGroup': null,
      },
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${group['title'] ?? 'Title group'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Môn: ${group['subject'] ?? 'Không xác định'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Số lượng thành viên: ${group['memberCount'] ?? '0'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
