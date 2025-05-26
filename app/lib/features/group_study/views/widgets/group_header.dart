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

    return group?.imgGroup == null
        ? const SizedBox()
        : Stack(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  group!.imgGroup!,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.black.withOpacity(0.4),
              ),
              Positioned(
                left: 16,
                bottom: 24,
                child: Text(
                  group?.name ?? 'Không tên',
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 36,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
  }
}
