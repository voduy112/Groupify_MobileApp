import 'package:app/features/document_share/providers/document_share_provider.dart';
import 'package:app/features/home/widgets/list_group_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Carousel_view.dart';
import '../../authentication/providers/auth_provider.dart';
import '../widgets/list_document_item.dart';
import '../../../core/widgets/title_app.dart';
import '../widgets/list_group_item.dart';
import '../../group_study/providers/group_provider.dart';
import 'notification_screen.dart';
import '../../../services/notification/messaging_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (currentUser != null) {
      // Fetch noti ngay khi vào HomeScreen
      Provider.of<MessagingProvider>(context, listen: false)
          .fetchAllNotification(currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).user?.id;
    final messagingProvider = Provider.of<MessagingProvider>(context);

    // Lấy số lượng notification chưa đọc
    final unreadCount =
        messagingProvider.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
        actions: [
          IconButton(
            onPressed: () async {
              // Khi mở dialog, có thể fetch lại để đảm bảo dữ liệu mới nhất
              await messagingProvider.fetchAllNotification(currentUser!);
              await showDialog(
                context: context,
                useSafeArea: true,
                barrierDismissible: true,
                builder: (context) => Center(
                  child: NotificationScreen(userId: currentUser),
                ),
              );
              // Sau khi đóng dialog, fetch lại để cập nhật trạng thái đã đọc
              await messagingProvider.fetchAllNotification(currentUser);
            },
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyCarouselView(),
              SizedBox(height: 15),
              TitleApp(title: 'Tài liệu', context: context),
              ListDocumentItem(),
              TitleApp(title: 'Nhóm', context: context),
              SizedBox(height: 10),
              ListGroupItem(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/home/upload-document');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
