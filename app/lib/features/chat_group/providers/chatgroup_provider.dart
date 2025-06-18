import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/group_message.dart';
import '../services/chatgroup_service.dart';

class ChatgroupProvider with ChangeNotifier {
  final ChatgroupService chatgroupService;

  ChatgroupProvider({required this.chatgroupService});

  List<GroupMessage> _messages = [];
  bool _isLoading = false;
  bool _isSendingImage = false;

  List<GroupMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSendingImage => _isSendingImage;

  // Lấy tin nhắn nhóm
  Future<void> getGroupMessages(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await chatgroupService.getGroupMessages(groupId);
    } catch (e) {
      debugPrint("Lỗi khi lấy tin nhắn nhóm: $e");
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMessage(GroupMessage message) {
    final exists = _messages.any((msg) => msg.id == message.id);
    if (!exists) {
      _messages.add(message);
      notifyListeners();
    }
  }

  void setMessages(List<GroupMessage> messages) {
    _messages = messages;
    notifyListeners();
  }

  // Gửi ảnh nhóm
  Future<void> sendGroupImage({
    required File imageFile,
    required String fromUserId,
    required String groupId,
  }) async {
    if (_isSendingImage) return; // Ngăn gửi trùng
    _isSendingImage = true;
    notifyListeners();

    try {
      await chatgroupService.uploadImageAndReturnMessage(
        imageFile,
        fromUserId: fromUserId,
        groupId: groupId,
      );

      // Tin nhắn sẽ đến từ socket event 'groupMessage'
    } catch (e) {
      debugPrint('Lỗi khi gửi ảnh nhóm: $e');
    } finally {
      _isSendingImage = false;
      notifyListeners();
    }
  }
}
