import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../views/chat_user_card.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  List<User> _filteredUsers = [];

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialChatList());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreChatList();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterUsers();
      });
    });
  }

  Future<void> _loadInitialChatList() async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      _currentPage = 1;
      context.read<ChatProvider>().resetChatList();
      final hasMore =
          await context
          .read<ChatProvider>()
          .fetchChatListPage(currentUser.id!, page: _currentPage);
      setState(() {
        _hasMore = hasMore;
        _filterUsers();
      });
    }
  }

  Future<void> _loadMoreChatList() async {
    setState(() => _isLoadingMore = true);
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      final hasMore =
          await context.read<ChatProvider>().fetchChatListPage(currentUser.id!);
      setState(() {
        _currentPage++;
        _hasMore = hasMore;
        _isLoadingMore = false;
        _filterUsers();
      });
    }
  }

  void _filterUsers() {
    final chatProvider = context.read<ChatProvider>();
    _filteredUsers = chatProvider.chatUsers
        .where((user) =>
            user.username?.toLowerCase().contains(_searchQuery) ?? false)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Trò chuyện")),
      body: chatProvider.isLoading && _currentPage == 1
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.error != null
              ? Center(child: Text('Lỗi: ${chatProvider.error}'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm',
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'Không tìm thấy người dùng!',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredUsers.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_isLoadingMore &&
                                    index == _filteredUsers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final user = _filteredUsers[index];
                                final lastMessages =
                                    chatProvider.lastMsgs[user.id] ?? '';
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  child: ChatUserCard(
                                    user: user,
                                    lastMsg: lastMessages,
                                    onTap: () {
                                      final currentUser =
                                          context.read<AuthProvider>().user;
                                      if (currentUser != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              currentUserId: currentUser.id!,
                                              otherUser: user,
                                            ),
                                          ),
                                        ).then((_) => _loadInitialChatList());
                                      }
                                    },
                                    onDelete: () async {
                                      final currentUserId =
                                          context.read<AuthProvider>().user?.id;
                                      if (currentUserId != null) {
                                        await context
                                            .read<ChatProvider>()
                                            .deleteChatWithUser(
                                                currentUserId, user.id!);
                                        _filterUsers();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
