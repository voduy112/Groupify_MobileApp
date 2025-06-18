import 'package:flutter/material.dart';
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
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchingMore = false;

  List<Message> get messages => _messages;
  List<User> get chatUsers => _chatUsers;
  Map<String, String> get lastMsgs => _lastMsgs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _currentPage <= _totalPages;

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

  Future<void> fetchChatList(String userId, {bool refresh = false}) async {
    if (refresh) {
      _chatUsers.clear();
      _currentPage = 1;
    }

    if (_isFetchingMore) return;

    _isLoading = _currentPage == 1;
    _isFetchingMore = _currentPage > 1;
    _error = null;
    notifyListeners();

    try {
      final data = await chatService.getChatList(userId, page: _currentPage);
      final users = data['chats'] as List<User>;
      final totalPages = data['totalPages'] as int;
      final lastMsgsMap = data['lastMsgs'] as Map<String, String>;

      _chatUsers.addAll(users);
      _lastMsgs.addAll(lastMsgsMap);
      _totalPages = totalPages;
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> fetchChatListPage(String userId, {int? page}) async {
    if (page != null) {
      _currentPage = page;
    }
    await fetchChatList(userId);
    return hasMore;
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> deleteChatWithUser(
      String currentUserId, String otherUserId) async {
    await chatService.deleteChat(currentUserId, otherUserId);
    _chatUsers.removeWhere((user) => user.id == otherUserId);
    _lastMsgs.remove(otherUserId);
    notifyListeners();
  }

  void setMessages(List<Message> messages) {
    _messages = messages;
    notifyListeners();
  }

  void resetChatList() {
    _chatUsers.clear();
    _lastMsgs.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

}
