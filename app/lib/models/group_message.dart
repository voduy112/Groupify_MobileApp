import 'package:app/models/user.dart';

class GroupMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final User fromUser;
  final String? imageUrl;
  final String groupId;
  final bool isUploading;

  GroupMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.fromUser,
    this.imageUrl,
    required this.groupId,
    this.isUploading = false,
  });


  String get fromUserId => fromUser.id!;

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['_id'],
      message: json['message'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      fromUser: json['fromUserId'] is Map
          ? User.fromJson(json['fromUserId'])
          : User(id: json['fromUserId'] ?? '', username: ''),
      imageUrl: json['imageUrl'] as String?,
      groupId:
          json['groupId'] is Map ? json['groupId']['_id'] : json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'fromUserId': fromUser.toJson(),
      'groupId': groupId,
      'imageUrl': imageUrl,
    };
  }
}
