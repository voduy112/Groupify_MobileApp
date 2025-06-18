import 'package:app/models/user.dart';

class Message {
  final String id;
  final User fromUser;
  final User toUser;
  final String message;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      fromUser: json['fromUserId'] is Map
          ? User.fromJson(json['fromUserId'])
          : User(id: json['fromUserId'], username: ''),
      toUser: json['toUserId'] is Map
          ? User.fromJson(json['toUserId'])
          : User(id: json['toUserId'], username: ''),

      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUser.toJson(),
      'toUserId': toUser.toJson(),
      'message': message,
      'timestamp': timestamp.toIso8601String()
    };
  }
}
