import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import 'group_item.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import 'create_group_screen.dart';
import '../../../core/utils/session_expired_handler.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/widgets/custom_appbar.dart';

class GroupStudyScreen extends StatefulWidget {
  const GroupStudyScreen({super.key});

  @override
  State<GroupStudyScreen> createState() => _GroupStudyScreenState();
}

class _GroupStudyScreenState extends State<GroupStudyScreen> {
  @override
  void initState() {
    super.initState();
    // Đợi đến khi context sẵn sàng
    Future.delayed(Duration.zero, () {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId != null) {
        Provider.of<GroupProvider>(context, listen: false)
            .fetchGroupsByUserId(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Nhóm của bạn"),
      body: Consumer<GroupProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return ListView.builder(
              itemCount: provider.groups.length,
              itemBuilder: (context, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
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
          } else if (provider.error != null) {
            handleSessionExpired(context, provider.error);
            return Center(child: Text('Lỗi: ${provider.error}'));
          } else if (provider.groups.isEmpty) {
            return const Center(child: Text('Chưa có nhóm nào.'));
          }

          return ListView.builder(
            itemCount: provider.groups.length,
            itemBuilder: (context, index) {
              return GroupItem(
                group: provider.groups[index],
                onTap: () {
                  context.push(
                      '/group/detail-group/${provider.groups[index].id!}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateGroupScreen()),
            );
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
          tooltip: 'Tạo nhóm mới',
        ),
      ),
    );
  }
}
