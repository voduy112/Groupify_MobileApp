import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../models/document.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentItem extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final String currentUserId;
  final String groupOwnerId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentItem({
    super.key,
    required this.document,
    this.onTap,
    required this.currentUserId,
    required this.groupOwnerId,
    this.onEdit,
    this.onDelete,
  });
  bool get isOwner => currentUserId == groupOwnerId;

  Future<bool> requestStoragePermission() async {
    final statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    return statuses[Permission.storage]!.isGranted;
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final url = document.mainFile;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy file để tải xuống')),
      );
      return;
    }

    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần cấp quyền lưu trữ')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = Directory('/storage/emulated/0/Download');

        // Đảm bảo thư mục tồn tại
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final fileName = url.split('/').last + '.pdf';
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tải về: $fileName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải thất bại (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.blue[200]!,
            width: 1.5,
          ),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: document.imgDocument ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.title ?? 'Tên tài liệu',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mô tả: ${document.description ?? 'Không xác định'}',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.download_rounded, color: Colors.blue),
                    onPressed: () => _downloadPdf(context),
                  ),
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
