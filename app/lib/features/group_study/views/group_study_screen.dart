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
import './search_group_screen.dart';
import '../../../core/widgets/shimmer.dart';

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
      appBar: CustomAppBar(
        title: "Nhóm của bạn",
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Tìm kiếm nhóm',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchGroupScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Tạo nhóm mới',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const GroupListShimmer();
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
    );
  }
}
