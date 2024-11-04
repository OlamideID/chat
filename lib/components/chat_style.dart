import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble(
      {super.key,
      required this.isCurrentUser,
      required this.message,
      required this.messageID,
      required this.userID});
  final bool isCurrentUser;
  final String message;
  final String messageID;
  final String userID;

  final ChatService _chatService = ChatService();

  showOptions(BuildContext context, String messageID, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report'),
              onTap: () {
                Navigator.of(context).pop();
                _reportMessage(context, messageID, userID);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () {
                Navigator.of(context).pop();
                _chatService.blockUser(userID);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _reportMessage(BuildContext context, String userID, String messageID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: const Text('Are you sure you want to report this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ChatService().reportUser(userID, messageID);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message Reported')));
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (!isCurrentUser) {
          showOptions(context, messageID, userID);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isCurrentUser ? Colors.blue[700] : Colors.grey),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
