import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/user.dart';
import '../../../models/message.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../profile/views/profile_screen.dart';
import '../providers/chat_provider.dart';
import '../widget/error_banner.dart';
import '../../../services/notification/messaging_provider.dart';
import '../../socket/socket_provider.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final User otherUser;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final socketProvider = context.read<SocketProvider>();

    socketProvider.joinRoom(widget.currentUserId, widget.otherUser.id!);
    socketProvider.loadMessages(widget.currentUserId, widget.otherUser.id!);

    socketProvider.listenChatHistory(
      (msgs) {
        if (!mounted) return;
        context.read<ChatProvider>().setMessages(msgs);
        setState(() => _errorMsg = null);
        _scrollToBottom();
      },
      () {
        if (!mounted) return;
        setState(
            () => _errorMsg = 'Không thể hiển thị tin nhắn. Vui lòng thử lại.');
      },
    );

    socketProvider.listenPrivateMessage((msg) {
      final isValid = (msg.fromUser.id == widget.otherUser.id &&
              msg.toUser.id == widget.currentUserId) ||
          (msg.fromUser.id == widget.currentUserId &&
              msg.toUser.id == widget.otherUser.id);

      if (isValid && mounted) {
        context.read<ChatProvider>().addMessage(msg);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchMessages(
            widget.currentUserId,
            widget.otherUser.id!,
          );
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      context.read<SocketProvider>().sendPrivateMessage(
            widget.currentUserId,
            widget.otherUser.id!,
            text,
          );
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Không gửi được tin nhắn. Vui lòng thử lại.';
      });
      return;
    }

    try {
      final senderName =
          context.read<AuthProvider>().user?.username ?? 'Người dùng';
      await context.read<MessagingProvider>().sendPersonalChatNotification(
            widget.otherUser.id!,
            senderName,
            text,
          );
    } catch (e) {
      print('Lỗi gửi notification: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(position + 50);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatProvider>().messages;
    final isLoading = context.watch<ChatProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () async {
            try {
              final fullUser = await context
                  .read<AuthProvider>()
                  .authService
                  .fetchUserProfileById(widget.otherUser.id!);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: fullUser),
                ),
              );
            } catch (e) {
              print('Không thể tải thông tin user: $e');
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (widget.otherUser.profilePicture != null &&
                        widget.otherUser.profilePicture!.isNotEmpty)
                    ? NetworkImage(widget.otherUser.profilePicture!)
                    : null,
                backgroundColor: Colors.grey.shade300,
                child: (widget.otherUser.profilePicture == null ||
                        widget.otherUser.profilePicture!.isEmpty)
                    ? Text(
                        widget.otherUser.username != null
                            ? widget.otherUser.username![0].toUpperCase()
                            : '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(widget.otherUser.username ?? ''),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMsg != null)
                  ErrorBanner(
                    message: _errorMsg!,
                    onRetry: () {
                      Navigator.pop(context);
                    },
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.fromUser.id == widget.currentUserId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: msg.fromUser.profilePicture !=
                                        null
                                    ? NetworkImage(msg.fromUser.profilePicture!)
                                    : null,
                                backgroundColor: Colors.grey.shade400,
                                child: msg.fromUser.profilePicture == null
                                    ? Text(
                                        msg.fromUser.username
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : null,
                              ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.50,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.blue.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.fromUser.username ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      msg.message,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('HH:mm').format(msg.timestamp),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
