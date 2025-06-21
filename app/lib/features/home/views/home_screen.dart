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
import 'package:shimmer/shimmer.dart';

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
      // Fetch notification luôn (nếu muốn)
      Provider.of<MessagingProvider>(context, listen: false)
          .fetchAllNotification(currentUser);

      // Chỉ fetch group nếu chưa có dữ liệu
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      if (groupProvider.groups.isEmpty) {
        Future.microtask(() => groupProvider.fetchAllGroup(currentUser));
      }

      // Chỉ fetch document nếu chưa có dữ liệu
      final documentProvider =
          Provider.of<DocumentShareProvider>(context, listen: false);
      if (documentProvider.documents.isEmpty) {
        Future.microtask(() => documentProvider.fetchDocuments());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentUser = Provider.of<AuthProvider>(context).user?.id;
    final messagingProvider = Provider.of<MessagingProvider>(context);
    final documentProvider = Provider.of<DocumentShareProvider>(context);

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
              documentProvider.isLoading
                  ? DocumentListShimmer()
                  : ListDocumentItem(),
              TitleApp(title: 'Nhóm', context: context),
              groupProvider.isLoading ? GroupListShimmer() : ListGroupItem(),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/home/upload-document');
          },
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white, width: 1),
          ),
          elevation: 8,
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.blue.shade500,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DocumentListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 100,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 18,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 18,
                          width: 120,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 80,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
