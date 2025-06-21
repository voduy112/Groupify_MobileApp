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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
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

  void _onSearchChanged(String value) async {
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    try {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      final results = await provider.searchGroup(value);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
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
    final groups = groupProvider.groups;
    final showList = _searchQuery.isEmpty ? groups : _searchResults;

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
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : showList.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy nhóm nào',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: showList.length +
                            (_searchQuery.isEmpty &&
                                    groupProvider.isFetchingMore
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index < showList.length) {
                            final group = showList[index];
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
