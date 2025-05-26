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
  @override
  void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadChatList();
  });
}

  Future<void> _loadChatList() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (currentUser != null) {
      await Provider.of<ChatProvider>(context, listen: false)
          .fetchChatList(currentUser.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.error != null
              ? Center(child: Text('Lỗi: ${chatProvider.error}'))
              : ListView.builder(
                  itemCount: chatProvider.chatUsers.length,
                  itemBuilder: (context, index) {
                    final user = chatProvider.chatUsers[index];
                    final lastMessages = chatProvider.lastMsgs[user.id] ?? '';
                    return ChatUserCard(
                      user: user,
                      lastMsg: lastMessages,
                      onTap: () {
                        final currentUser =
                            Provider.of<AuthProvider>(context, listen: false)
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
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
