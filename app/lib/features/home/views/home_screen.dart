import 'package:app/features/document_share/providers/document_share_provider.dart';
import 'package:app/features/home/widgets/home_search.dart';
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
import '../../../core/widgets/custom_appbar.dart';

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nền gradient lớn, bo góc dưới
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding:
                  EdgeInsets.only(top: 36, left: 20, right: 20, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar custom
                  SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Welcome back!",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Groupify",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: () async {
                                await messagingProvider
                                    .fetchAllNotification(currentUser!);
                                await showDialog(
                                  context: context,
                                  useSafeArea: true,
                                  barrierDismissible: true,
                                  builder: (context) => Center(
                                    child:
                                        NotificationScreen(userId: currentUser),
                                  ),
                                );
                                await messagingProvider
                                    .fetchAllNotification(currentUser);
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  // Ô tìm kiếm
                  HomeSearch(),
                ],
              ),
            ),
            // Carousel (nổi lên nền trắng)
            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: MyCarouselView(),
            ),
            // Tiêu đề và nút 'Xem thêm...' trên cùng một hàng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleApp(title: 'Tài liệu', context: context),
                  TextButton(
                    onPressed: () {
                      context.push('/home/show-all-document');
                    },
                    child: Text(
                      'Xem thêm...',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách tài liệu
            documentProvider.isLoading
                ? DocumentListShimmer()
                : ListDocumentItem(),
            // Hiển thị lại phần nhóm nhưng không có cuộn bên trong
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleApp(title: 'Nhóm', context: context),
                  TextButton(
                    onPressed: () {
                      context.push('/home/show-all-group');
                    },
                    child: Text(
                      'Xem thêm...',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            groupProvider.isLoading ? GroupListShimmer() : ListGroupItem(),
          ],
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
