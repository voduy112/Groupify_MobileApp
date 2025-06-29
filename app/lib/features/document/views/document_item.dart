import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/document.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../providers/document_provider.dart';

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
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    }
    return true;
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

  Widget _popupButton(BuildContext context, String label, String value) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // đóng popup
        // gọi onSelected bằng cách gọi lại PopupMenuButton logic
        switch (value) {
          case 'download':
            _downloadPdf(context);
            break;
          case 'edit':
            if (onEdit != null) onEdit!();
            break;
          case 'delete':
            if (onDelete != null) onDelete!();
            break;
        }
      },
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
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
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        elevation: 3,
        shadowColor: Colors.blue[200],
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
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        ),
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      _downloadPdf(context);
                      break;
                    case 'edit':
                      if (onEdit != null) onEdit!();
                      break;
                    case 'delete':
                      if (onDelete != null) onDelete!();
                      break;
                  }
                },
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                color: Colors.white,
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _popupButton(context, 'Tải xuống', 'download'),
                        if (isOwner) _popupButton(context, 'Chỉnh sửa', 'edit'),
                        if (isOwner) _popupButton(context, 'Xoá', 'delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


