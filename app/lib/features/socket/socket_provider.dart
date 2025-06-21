import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../models/group_message.dart';
import '../../models/message.dart';

class SocketEvent {
  final String event;
  final dynamic data;

  SocketEvent(this.event, this.data);
}

class SocketProvider with ChangeNotifier {
  late IO.Socket _socket;
  final _controller = StreamController<SocketEvent>.broadcast();

  bool _initialized = false;

  Stream<SocketEvent> get stream => _controller.stream;
  bool get isConnected => _socket.connected;

  void connect(String url, {Map<String, dynamic>? queryParams, String? token}) {
    if (_initialized) return;
    _initialized = true;

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery(queryParams ?? {})
          .setExtraHeaders({'Authorization': token ?? ''})
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      _emit(SocketEvent('connect', null));
      print('Socket connected');
    });

    _socket.onDisconnect((_) {
      _emit(SocketEvent('disconnect', null));
      print('Socket disconnected');
    });

    _socket.onError((data) {
      _emit(SocketEvent('error', data));
      print('Socket error: $data');
    });
  }

  // chat 1v1
  void joinRoom(String fromUserId, String toUserId) {
    emit('joinRoom', {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    });
  }

  void loadMessages(String fromUserId, String toUserId,
      {int page = 1, int limit = 20}) {
    emit('loadMessages', {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'page': page,
      'limit': limit,
    });
  }


  void sendPrivateMessage(String fromUserId, String toUserId, String message) {
    emit('privateMessage', {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message,
    });
  }

  void listenChatHistory(
    void Function(List<Message> messages, bool hasMore) onSuccess,
    VoidCallback onError,
  ) {
    _socket.on('chatHistory', (data) {
      try {
        final messages = (data['messages'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
        final hasMore = data['hasMore'] as bool? ?? false;

        onSuccess(messages, hasMore);
      } catch (e) {
        print('Lỗi xử lý chatHistory: $e');
        onError();
      }
    });
  }

  void listenPrivateMessage(Function(Message) onMessage) {
    listen('privateMessage', (data) {
      try {
        final msg = Message.fromJson(data);
        onMessage(msg);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  //chatgroup
  void joinGroupChat({required String groupId, required String userId}) {
    if (!_socket.connected) return;

    _socket.emit('joinGroup', {
      'groupId': groupId,
      'userId': userId,
    });

    _socket.emit('loadGroupMessages', {
      'groupId': groupId,
    });
  }

  void sendGroupMessage({
    required String groupId,
    required String fromUserId,
    required String message,
  }) {
    _socket.emit('groupMessage', {
      'groupId': groupId,
      'fromUserId': fromUserId,
      'message': message,
    });
  }

  void listenGroupChatEvents({
    required void Function(GroupMessage) onNewMessage,
    required void Function(List<GroupMessage>) onHistoryLoaded,
    required void Function(Object) onError,
  }) {
    _socket.on('groupMessage', (data) {
      try {
        final msg = GroupMessage.fromJson(data);
        print("🔥 Nhận được groupMessage socket: $data");
        onNewMessage(msg);
      } catch (e) {
        onError(e);
      }
    });

    _socket.on('groupChatHistory', (data) {
      try {
        final msgs = List<GroupMessage>.from(
          data.map((json) => GroupMessage.fromJson(json)),
        );
        onHistoryLoaded(msgs);
      } catch (e) {
        onError(e);
      }
    });
  }

  void listen(String event, Function(dynamic data) handler) {
    _socket.on(event, handler);
  }

  void emit(String event, dynamic data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    }
  }

  void _emit(SocketEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
      _socket.dispose();
    }
    _controller.close();

    _initialized = false;
  }

  void off(String event) {
    _socket.off(event);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
