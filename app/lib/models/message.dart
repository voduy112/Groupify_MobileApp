import 'package:app/models/user.dart';

class Message {
  final String id;
  final User fromUser;
  final User toUser;
  final String message;
  final DateTime timestamp;
  final String type;

  Message({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      fromUser: User.fromJson(json['fromUserId']),
      toUser: User.fromJson(json['toUserId']),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      type: json['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUser.toJson(),
      'toUserId': toUser.toJson(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
