import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../group_study/views/group_item.dart';
import '../../group_study/providers/group_provider.dart';
import '../../group_study/views/group_detail_screen.dart';
import '../../authentication/providers/auth_provider.dart';

class ShowAllGroupScreen extends StatefulWidget {
  const ShowAllGroupScreen({super.key});

  @override
  State<ShowAllGroupScreen> createState() => _ShowAllGroupScreenState();
}

class _ShowAllGroupScreenState extends State<ShowAllGroupScreen> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    // Lấy userId từ Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      userId = authProvider.user?.id;
      if (userId != null) {
        Provider.of<GroupProvider>(context, listen: false)
            .fetchAllGroup(userId!);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = Provider.of<GroupProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoading &&
        provider.currentPage < provider.totalPages) {
      provider.fetchMoreGroups(userId!);
      print('fetchMoreGroups');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final filteredGroups = groupProvider.groups.where((group) {
      final name = group.name?.toLowerCase() ?? '';
      final description = group.description?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả nhóm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm nhóm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: filteredGroups.isEmpty
                ? const Center(child: Text('Không tìm thấy nhóm nào'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredGroups.length +
                        (groupProvider.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < filteredGroups.length) {
                        final group = filteredGroups[index];
                        return GroupItem(
                          group: group,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  GroupDetailScreen(groupId: group.id!),
                            ));
                          },
                        );
                      } else {
                        // Hiển thị loading khi đang fetch trang mới
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
