class Message {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String message;
  final DateTime timestamp;
  final String? fromUsername;
  final String? toUsername;

  Message({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.timestamp,
    this.fromUsername,
    this.toUsername,
    
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      fromUserId: json['fromUserId'] is Map
          ? json['fromUserId']['_id']
          : json['fromUserId'],
      toUserId:
          json['toUserId'] is Map ? json['toUserId']['_id'] : json['toUserId'],
      fromUsername:
          json['fromUserId'] is Map ? json['fromUserId']['username'] : null,
      toUsername: json['toUserId'] is Map ? json['toUserId']['username'] : null,
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}