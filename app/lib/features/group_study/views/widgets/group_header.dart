import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../models/group.dart';

class GroupHeader extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Group? group;

  const GroupHeader({
    super.key,
    required this.isLoading,
    required this.error,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Lỗi: $error')),
      );
    }

    // Không render gì nữa vì AppBar đã hiển thị tên nhóm
    return const SizedBox.shrink();
  }
}
