import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../models/user.dart';
import '../../../models/message.dart'; 
import 'package:intl/intl.dart';

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
  late IO.Socket socket;
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.1.175:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print("Socket connected");
      socket.emit('joinRoom', {
        'fromUserId': widget.currentUserId,
        'toUserId': widget.otherUser.id,
      });

      // Lấy lịch sử
      socket.emit('loadMessages', {
        'fromUserId': widget.currentUserId,
        'toUserId': widget.otherUser.id,
      });
    });

    socket.on('chatHistory', (data) async{
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        messages = List<Message>.from(
            data.map((json) => Message.fromJson(json)).toList());
        _isloading = false;
      });

      _scrollToBottom();
    });

    socket.on('privateMessage', (data) {
      setState(() {
        messages.add(Message.fromJson(data));
      });

      _scrollToBottom();
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    socket.emit('privateMessage', {
      'fromUserId': widget.currentUserId,
      'toUserId': widget.otherUser.id,
      'message': text,
    });

    _controller.clear();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: (widget.otherUser.profilePicture != null &&
                      widget.otherUser.profilePicture!.isNotEmpty)
                  ? NetworkImage(widget.otherUser.profilePicture!)
                  : null,
              child: (widget.otherUser.profilePicture == null ||
                      widget.otherUser.profilePicture!.isEmpty)
                  ? Text(widget.otherUser.username![0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
            Text(widget.otherUser.username ?? ''),
          ],
        ),
      ),
      body: _isloading
      ? const Center(child: CircularProgressIndicator())
      : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 50),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.fromUserId == widget.currentUserId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(msg.timestamp),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        )
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
                      hintText: 'Nhập tin nhắn...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
