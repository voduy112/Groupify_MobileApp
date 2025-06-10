import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _searchQuery = '';
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatList();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterUsers();
      });
    });
  }

  Future<void> _loadChatList() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (currentUser != null) {
      await Provider.of<ChatProvider>(context, listen: false)
          .fetchChatList(currentUser.id!);
      _filterUsers();
    }
  }

  void _filterUsers() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    setState(() {
      _filteredUsers = chatProvider.chatUsers
          .where((user) => user.username!.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Trò chuyện")),
      body: chatProvider.isLoading
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
                            borderSide: const BorderSide(),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
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
                                final currentUser = Provider.of<AuthProvider>(
                                        context,
                                        listen: false)
                                    .user;
                                if (currentUser != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        currentUserId: currentUser.id!,
                                        otherUser: user,
                                      ),
                                    ),
                                  ).then((_) {
                                    _loadChatList();
                                  });
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
                                  setState(() {
                                    _filterUsers();
                                  });
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
