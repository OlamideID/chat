import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
    required this.messageID,
    required this.userID,
    required this.isRead,
    required this.timestamp,
    required this.isReceiverNewMessage, // Add the isReceiver parameter
  });

  final bool isCurrentUser;
  final String message;
  final String messageID;
  final String userID;
  final bool isRead;
  final Timestamp timestamp;
  final bool
      isReceiverNewMessage; // New parameter to determine if receiver sent a new message

  final ChatService _chatService = ChatService();

  void showOptions(BuildContext context, String messageUserID) {
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
                _reportMessage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block'),
              onTap: () {
                Navigator.of(context).pop();
                _chatService.blockUser(userID);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Blocked')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reportMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Message'),
          content: const Text('Are you sure you want to report this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _chatService.reportUser(userID, messageID);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message Reported')),
                );
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
          showOptions(context, userID);
        }
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color(0xFFDCF8C6)
                : Colors.white, // WhatsApp green and gray for other user
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft:
                  isCurrentUser ? const Radius.circular(15) : Radius.zero,
              bottomRight:
                  isCurrentUser ? Radius.zero : const Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width *
                0.75, // Max width for bubbles
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.black : Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  if (isCurrentUser)
                    Icon(
                      Icons.done_all,
                      color: isReceiverNewMessage
                          ? Colors.purple
                          : (isRead ? Colors.purple : Colors.grey[400]),
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    // Format timestamp like WhatsApp
    if (difference.inDays == 0) {
      // Today, display time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Last 7 days
      return dateTime.weekday == 1
          ? "Mon"
          : dateTime.weekday == 2
              ? "Tue"
              : dateTime.weekday == 3
                  ? "Wed"
                  : dateTime.weekday == 4
                      ? "Thu"
                      : dateTime.weekday == 5
                          ? "Fri"
                          : dateTime.weekday == 6
                              ? "Sat"
                              : "Sun";
    } else {
      // Older dates
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }
}
