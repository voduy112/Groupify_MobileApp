import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService chatService;

  ChatProvider({required this.chatService});

  List<Message> _messages = [];
  List<User> _chatUsers = [];
  Map<String, String> _lastMsgs = {};
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  List<User> get chatUsers => _chatUsers;
  Map<String, String> get lastMsgs => _lastMsgs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMessages(String user1Id, String user2Id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await chatService.getMessages(user1Id, user2Id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChatList(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final users = await chatService.getChatList(userId);
      _chatUsers = users;
      _lastMsgs.clear();

      for (var user in users) {
        final msgs = await chatService.getMessages(userId, user.id!);
        if (msgs.isNotEmpty) {
          final lastMsg = msgs.last;
          final isCurrentUserSender = lastMsg.fromUser.id == userId;

          final displayUserId = lastMsg.fromUser.id == userId
              ? lastMsg.toUser.id
              : lastMsg.fromUser.id;

          _lastMsgs[displayUserId!] =
              isCurrentUserSender ? 'Bạn: ${lastMsg.message}' : lastMsg.message;
        } else {
          _lastMsgs[user.id!] = '';
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _chatUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }
  
  Future<void> deleteChatWithUser(String currentUserId, String otherUserId) async {
    await chatService.deleteChat(currentUserId, otherUserId);
    _chatUsers.removeWhere((user) => user.id == otherUserId);
    _lastMsgs.remove(otherUserId);
    notifyListeners();
  }

}
