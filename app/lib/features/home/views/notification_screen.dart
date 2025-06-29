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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Thông báo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0072ff),
                          fontSize: 22,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final noti = notifications[index];
                      return Material(
                        color: noti.isRead
                            ? Colors.white
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFe3f0ff),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    _iconForType(noti.type),
                                    color: const Color(0xFF0072ff),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              noti.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (!noti.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(
                                                  left: 4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        noti.body,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${noti.createdAt.day}/${noti.createdAt.month}/${noti.createdAt.year} '
                                        '${noti.createdAt.hour}:${noti.createdAt.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Provider.of<MessagingProvider>(context,
                                  listen: false)
                              .readAllNotification(widget.userId);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0072ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Đọc tất cả',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Đóng',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
