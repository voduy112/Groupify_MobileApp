import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../views/chat_user_card.dart';
import 'chat_screen.dart';
import '../../../core/widgets/custom_appbar.dart';

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
  bool _isSearching = false;
  bool _isSearchMode = false;

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

    _searchController.addListener(() async {
      final query = _searchController.text.trim();
      final currentUser = context.read<AuthProvider>().user;

      setState(() {
        _searchQuery = query;
      });

      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
        });
        _filterUsers();
        return;
      }

      if (currentUser != null) {
        final results = await context
            .read<ChatProvider>()
            .searchChat(currentUser.id!, query);

        setState(() {
          _isSearching = true;
          _filteredUsers = results;
        });
      }
    });
  }

  Future<void> _loadInitialChatList() async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      _currentPage = 1;
      context.read<ChatProvider>().resetChatList();
      final hasMore = await context
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0072ff), Color.fromARGB(255, 92, 184, 241)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              if (_isSearchMode)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearchMode = false;
                      _searchController.clear();
                      _searchQuery = '';
                      _isSearching = false;
                      _filterUsers();
                    });
                  },
                ),
              const SizedBox(width: 4),
              Expanded(
                child: _isSearchMode
                    ? Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm',
                              hintStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              prefixIcon: Icon(Icons.search, size: 20),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trò chuyện',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isSearchMode = true;
                              });
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      body: chatProvider.isLoading && _currentPage == 1
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.error != null
              ? Center(child: Text('Lỗi: ${chatProvider.error}'))
              : Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    //   child: TextField(
                    //     controller: _searchController,
                    //     decoration: InputDecoration(
                    //       labelText: 'Tìm kiếm',
                    //       prefixIcon: const Icon(Icons.search),
                    //       contentPadding: const EdgeInsets.symmetric(
                    //           vertical: 10, horizontal: 16),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //         borderSide: BorderSide(
                    //           color: Theme.of(context).primaryColor,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: (_isSearching
                                  ? _filteredUsers
                                  : chatProvider.chatUsers)
                              .isEmpty
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
                              itemCount: (_isSearching
                                      ? _filteredUsers.length
                                      : chatProvider.chatUsers.length) +
                                  (_isLoadingMore && !_isSearching ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_isLoadingMore &&
                                    !_isSearching &&
                                    index == chatProvider.chatUsers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final user = _isSearching
                                    ? _filteredUsers[index]
                                    : chatProvider.chatUsers[index];
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
                                        if (_isSearching) {
                                          _searchController.text =
                                              ''; // reset search
                                        }
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
