import 'package:flutter/material.dart';
import '../../../models/user.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final User otherUser;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUser.username!),
      ),
      body: Center(
        child: Text('Chat giữa $currentUserId và ${otherUser.username}'),
      ),
    );
  }
}
