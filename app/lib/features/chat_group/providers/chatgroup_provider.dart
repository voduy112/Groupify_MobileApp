import 'dart:io';

import 'package:flutter/material.dart';
import '../../../models/group_message.dart';
import '../services/chatgroup_service.dart';

class ChatgroupProvider with ChangeNotifier {
  final ChatgroupService chatgroupService;

  ChatgroupProvider({required this.chatgroupService});

  List<GroupMessage> _messages = [];
  bool _isLoading = false;

  List<GroupMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  //lay tin nhan nhom
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

  //ham gui anh
  Future<void> sendGroupImage({
    required File imageFile,
    required String fromUserId,
    required String groupId,
  }) async {
    try {
      // Chỉ gửi ảnh, không xử lý kết quả trả về
      await chatgroupService.uploadImageAndReturnMessage(
        imageFile,
        fromUserId: fromUserId,
        groupId: groupId,
      );

      // Không thêm tin nhắn vào _messages ở đây.
      // Tin nhắn sẽ đến từ socket: 'groupMessage'
    } catch (e) {
      debugPrint('Lỗi khi gửi ảnh nhóm: $e');
    }
  }


}
