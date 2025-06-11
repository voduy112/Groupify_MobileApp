import 'package:flutter/material.dart';
import '../../../services/notification/messaging_provider.dart';
import '../../../models/notification.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({required this.userId, super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<AppNotification>> _futureNoti;

  @override
  void initState() {
    super.initState();
    _futureNoti = _fetchNotifications();
  }

  Future<List<AppNotification>> _fetchNotifications() async {
    final data = await MessagingProvider().getAllNotification(widget.userId);
    return data
        .map<AppNotification>((json) => AppNotification.fromJson(json))
        .toList();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'join_request':
        return Icons.group_add;
      case 'join_accepted':
        return Icons.check_circle;
      case 'group_document':
        return Icons.insert_drive_file;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<AppNotification>>(
          future: _futureNoti,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Lỗi: ${snapshot.error}')),
              );
            }
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('Không có thông báo nào')),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Thông báo',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final noti = notifications[index];
                      return ListTile(
                        leading:
                            Icon(_iconForType(noti.type), color: Colors.blue),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                noti.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (!noti.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(noti.body),
                            Text(
                              '${noti.createdAt.day}/${noti.createdAt.month}/${noti.createdAt.year} ${noti.createdAt.hour}:${noti.createdAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (!noti.isRead) {
                            await Provider.of<MessagingProvider>(context,
                                    listen: false)
                                .readNotification(noti.id);
                            setState(() {
                              noti.isRead = true;
                            });
                          }
                          if (noti.type == 'join_request' ||
                              noti.type == 'join_accepted' ||
                              noti.type == 'group_document') {
                            context.go('/group/detail-group/${noti.groupId}');
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
