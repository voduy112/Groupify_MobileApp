import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../models/group_message.dart';
import '../../../models/user.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../chat/widget/error_banner.dart';
import '../../profile/views/profile_screen.dart';
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
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.1.227:5000', <String, dynamic>{
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
      try {
        final List<GroupMessage> msgs = List<GroupMessage>.from(
          data.map((json) => GroupMessage.fromJson(json)).toList(),
        );
        context.read<ChatgroupProvider>().setMessages(msgs);
        setState(() {
          _errorMsg = null;
        });
        _scrollToBottom();
      } catch (e) {
        setState(() {
          _errorMsg = 'Không thể hiển thị tin nhắn nhóm. Vui lòng thử lại.';
        });
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      socket.emit('groupMessage', {
        'groupId': widget.groupId,
        'fromUserId': widget.currentUser.id,
        'message': text,
      });
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _errorMsg = 'Không gửi được tin nhắn. Vui lòng thử lại.';
      });
    }
  }

  void _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      File imageFile = File(picked.path);

      // Gửi ảnh qua API
      await context.read<ChatgroupProvider>().sendGroupImage(
            imageFile: imageFile,
            fromUserId: widget.currentUser.id!,
            groupId: widget.groupId,
          );

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _errorMsg = 'Không thể gửi ảnh: $e';
      });
    }
  }

  void _openImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(30),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
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
    socket.disconnect();
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
              //show thong bao loi neu khong gui duoc hoac khong load duoc tin nhan
              if (_errorMsg != null)
                ErrorBanner(
                  message: _errorMsg!,
                  onRetry: () {
                    Navigator.pop(context);
                  },
                ),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(bottom: 50),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.fromUser.id == widget.currentUser.id;
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
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final fullUser = await context
                                      .read<AuthProvider>()
                                      .authService
                                      .fetchUserProfileById(msg.fromUser.id!);
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
                              child: CircleAvatar(
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
                            ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5),
                            child: Container(
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
                                      fontSize: 20,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (msg.imageUrl != null &&
                                      msg.imageUrl!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () =>
                                          _openImageDialog(msg.imageUrl!),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxHeight: 200),
                                          child: Image.network(
                                            msg.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (msg.message.isNotEmpty)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(msg.message,
                                            style:
                                                const TextStyle(fontSize: 16))),
                                  const SizedBox(height: 3),
                                  Text(
                                    DateFormat('HH:mm').format(msg.timestamp),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMe) const SizedBox(width: 8),
                          if (isMe)
                            CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  widget.currentUser.profilePicture != null
                                      ? NetworkImage(
                                          widget.currentUser.profilePicture!)
                                      : null,
                              backgroundColor: Colors.grey.shade400,
                              child: widget.currentUser.profilePicture == null
                                  ? Text(
                                      widget.currentUser.username
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '',
                                      style:
                                          const TextStyle(color: Colors.white))
                                  : null,
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
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.blue),
                      onPressed: _pickAndSendImage,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn nhóm...',
                          border: InputBorder.none,
                        ),
                        onFieldSubmitted: (_) => _sendMessage(),
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
