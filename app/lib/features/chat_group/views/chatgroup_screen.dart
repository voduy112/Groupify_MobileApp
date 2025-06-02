import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../models/group_message.dart';
import '../../../models/user.dart';
import '../providers/chatgroup_provider.dart';

class ChatgroupScreen extends StatefulWidget {
  final String groupId;
  final User currentUser;
  final String groupName;
  final ScrollController scrollController;

  const ChatgroupScreen({
    Key? key,
    required this.groupId,
    required this.currentUser,
    required this.groupName,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ChatgroupScreen> createState() => _ChatgroupScreenState();
}

class _ChatgroupScreenState extends State<ChatgroupScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectSocket();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatgroupProvider>().getGroupMessages(widget.groupId);
    });
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.1.223:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('joinGroup', {
        'groupId': widget.groupId,
        'userId': widget.currentUser.id,
      });
      socket.emit('loadGroupMessages', {
        'groupId': widget.groupId,
      });
    });

    socket.on('groupMessage', (data) {
      final msg = GroupMessage.fromJson(data);
      context.read<ChatgroupProvider>().addMessage(msg);
      _scrollToBottom();
    });

    socket.on('groupChatHistory', (data) {
      final List<GroupMessage> msgs = List<GroupMessage>.from(
        data.map((json) => GroupMessage.fromJson(json)).toList(),
      );

      context.read<ChatgroupProvider>().setMessages(msgs);
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    socket.emit('groupMessage', {
      'groupId': widget.groupId,
      'fromUserId': widget.currentUser.id,
      'message': text,
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.scrollController.hasClients) {
        widget.scrollController
            .jumpTo(widget.scrollController.position.maxScrollExtent);
      }
    });
  }


  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatgroupProvider>().messages;
    final isLoading = context.watch<ChatgroupProvider>().isLoading;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(bottom: 50),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.fromUser.id == widget.currentUser.id;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
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
                                  fontSize: 16,
                                  color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.message,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg.timestamp != null
                                  ? DateFormat('HH:mm').format(msg.timestamp!)
                                  : '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
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
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn nhóm...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
