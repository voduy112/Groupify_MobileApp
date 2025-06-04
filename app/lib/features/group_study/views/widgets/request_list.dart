import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../grouprequest/providers/grouprequest_provider.dart';

class RequestListWidget extends StatefulWidget {
  final String groupId;

  const RequestListWidget({super.key, required this.groupId});

  @override
  State<RequestListWidget> createState() => _RequestListWidgetState();
}

class _RequestListWidgetState extends State<RequestListWidget> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = Provider.of<GroupRequestProvider>(context, listen: false)
        .fetchRequestsByGroupId(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        final provider = context.watch<GroupRequestProvider>();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = provider.requests;

        if (requests.isEmpty) {
          return const Center(child: Text('Không có yêu cầu nào.'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            // Ép kiểu cẩn thận và kiểm tra null
            final userRaw = request.userId;
            String username = 'Không rõ người dùng';
            String? avatarUrl;

            if (userRaw != null && userRaw is Map<String, dynamic>) {
              username =
                  userRaw['username']?.toString() ?? 'Không rõ người dùng';
              avatarUrl = userRaw['profilePicture']?.toString();
            }

            String requestTime = 'Không rõ thời gian';
            if (request.requestAt != null) {
              try {
                final parsedDate = DateTime.parse(request.requestAt!);
                requestTime = DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
              } catch (_) {}
            }

            return ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                onBackgroundImageError: (_, __) {},
              ),
              title: Text(username),
              subtitle: Text('Yêu cầu lúc: $requestTime'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Duyệt yêu cầu',
                    onPressed: () async {
                      final success =
                          await provider.approveRequest(request.id!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã duyệt yêu cầu')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lỗi khi duyệt yêu cầu')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Xóa yêu cầu',
                    onPressed: () async {
                      final success = await provider.deleteRequest(request.id!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa yêu cầu')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lỗi khi xóa yêu cầu')),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
