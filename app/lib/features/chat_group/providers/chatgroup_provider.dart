import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/group_message.dart';
import '../../../models/user.dart';
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

  // Thêm 1 tin nhắn mới vào danh sách (tránh trùng)
  /*void addMessage(GroupMessage message) {
    final exists = _messages.any((msg) => msg.id == message.id);
    if (!exists) {
      _messages.add(message);
      notifyListeners();
    }
  }*/

  void addMessage(GroupMessage message) {
    // Nếu có ảnh đang upload tạm thời (cùng fromUser và cùng timestamp gần nhau)
    final tempIndex = _messages.indexWhere((msg) =>
        msg.isUploading &&
        msg.fromUser.id == message.fromUser.id &&
        (msg.timestamp.difference(message.timestamp).inSeconds).abs() <= 5);

    if (tempIndex != -1) {
      _messages[tempIndex] = message; // thay ảnh tạm bằng ảnh thật
    } else {
      final exists = _messages.any((msg) => msg.id == message.id);
      if (!exists) {
        _messages.add(message);
      }
    }

    notifyListeners();
  }


  // Gán lại toàn bộ danh sách tin nhắn
  void setMessages(List<GroupMessage> messages) {
    _messages = messages;
    notifyListeners();
  }

  // Gửi ảnh nhóm và thêm message ngay lập tức
  Future<void> sendGroupImage({
    required File imageFile,
    required String fromUserId,
    required String groupId,
  }) async {
    if (_isSendingImage) return;
    _isSendingImage = true;
    notifyListeners();

    // Tạo tin nhắn tạm thời
    final tempMessage = GroupMessage(
      id: UniqueKey().toString(), 
      message: '',
      timestamp: DateTime.now(),
      fromUser: User(id: fromUserId),
      groupId: groupId,
      imageUrl: imageFile.path,
      isUploading: true,
    );

    _messages.add(tempMessage);
    notifyListeners();

    try {
      // Gửi ảnh và nhận lại tin nhắn
      final GroupMessage newMessage =
          await chatgroupService.uploadImageAndReturnMessage(
        imageFile,
        fromUserId: fromUserId,
        groupId: groupId,
      );

      //xoa anh tam thoi
      //_messages.removeWhere((m) => m.id == tempMessage.id);

      // Hiển thị ngay trong UI
      //_messages.add(newMessage);
    } catch (e) {
      debugPrint('Lỗi khi gửi ảnh nhóm: $e');
    } finally {
      _isSendingImage = false;
      notifyListeners();
    }
  }
}
