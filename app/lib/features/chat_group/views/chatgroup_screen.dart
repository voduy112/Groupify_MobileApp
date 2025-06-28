import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/group_message.dart';
import '../../../models/user.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../chat/widget/error_banner.dart';
import '../../profile/views/profile_screen.dart';
import '../../socket/socket_provider.dart';
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
  final TextEditingController _controller = TextEditingController();
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final socketProvider = context.read<SocketProvider>();
    final chatProvider = context.read<ChatgroupProvider>();

    socketProvider.joinGroupChat(
      groupId: widget.groupId,
      userId: widget.currentUser.id!,
    );

    socketProvider.listenGroupChatEvents(
      onNewMessage: (msg) {
        chatProvider.addMessage(msg);
        _scrollToBottom();
      },
      onHistoryLoaded: (messages) {
        chatProvider.setMessages(messages);
        setState(() {
          _errorMsg = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _errorMsg = 'Không thể hiển thị tin nhắn nhóm. Vui lòng thử lại.';
        });
      },
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      context.read<SocketProvider>().sendGroupMessage(
            groupId: widget.groupId,
            fromUserId: widget.currentUser.id!,
            message: text,
          );
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
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

      await context.read<ChatgroupProvider>().sendGroupImage(
            imageFile: imageFile,
            fromUserId: widget.currentUser.id!,
            groupId: widget.groupId,
          );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
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
                child: Image.network(imageUrl, fit: BoxFit.contain),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatgroupProvider>().messages;
    final isLoading = context.watch<ChatgroupProvider>().isLoading;
    final isSendingImage = context.watch<ChatgroupProvider>().isSendingImage;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (_errorMsg != null)
                ErrorBanner(
                  message: _errorMsg!,
                  onRetry: () => Navigator.pop(context),
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF2F2F7), // nền
                  child: ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.only(bottom: 70),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.fromUser.id == widget.currentUser.id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6),
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
                                        builder: (_) =>
                                            ProfileScreen(user: fullUser),
                                      ),
                                    );
                                  } catch (e) {
                                    print('Không thể tải thông tin user: $e');
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage:
                                      msg.fromUser.profilePicture != null
                                          ? NetworkImage(
                                              msg.fromUser.profilePicture!)
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
                            if (!isMe) const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.65,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color.fromARGB(255, 190, 235, 255)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
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
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (msg.imageUrl != null &&
                                        msg.imageUrl!.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: msg.isUploading
                                            ? Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.file(
                                                      File(msg.imageUrl!),
                                                      width: 200,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const Positioned.fill(
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : GestureDetector(
                                                onTap: () => _openImageDialog(
                                                    msg.imageUrl!),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxHeight: 200),
                                                    child: Image.network(
                                                      msg.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      width: 200,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    if (msg.message.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          msg.message,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    const SizedBox(height: 3),
                                    Text(
                                      DateFormat('HH:mm').format(msg.timestamp),
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
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
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : null,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, -1),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: isSendingImage ? null : _pickAndSendImage,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            hintText: 'Nhập tin nhắn nhóm...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF2F2F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
