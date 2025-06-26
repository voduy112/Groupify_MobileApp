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
  bool _showSearchBar = false;

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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        leading: _showSearchBar
            ? Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _showSearchBar = false;
                          _searchController.clear();
                          _searchQuery = '';
                          _searchResults = [];
                        });
                      },
                      tooltip: 'Thoát tìm kiếm',
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Quay lại',
                    ),
                  ),
                ),
              ),
        title: _showSearchBar
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nhóm...',
                    border: InputBorder.none,
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                  onChanged: _onSearchChanged,
                ),
              )
            : const Text('Tất cả nhóm'),
        actions: [
          if (!_showSearchBar)
            Container(
              margin: const EdgeInsets.only(right: 10.0, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.blue),
                tooltip: 'Tìm kiếm',
                onPressed: () {
                  setState(() {
                    _showSearchBar = true;
                  });
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
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
