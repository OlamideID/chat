import 'package:chat/components/user_tile.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class BlockedPage extends ConsumerWidget {
  BlockedPage(this.textStyle, {super.key});
  final TextStyle textStyle; 
  final ChatService chatService = ChatService();
  final Authservice authservice = Authservice();

  _showUnblockOption(BuildContext context, String userId, String userN) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock USer'),
        content: const Text('Are you sure you want to?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: textStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              chatService.unblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'You have unblocked $userN',
                ),
              ));
            },
            child: Text(
              'Unblock',
              style: textStyle,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String userID = authservice.currentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockedUsers(userID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Lottie.asset(''),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset('assets/Animation - 1730069741511.json',
                  height: 150, width: 150),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text('No blocked users'),
            );
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user['username'],
                onTap: () {
                  _showUnblockOption(context, user['uid'], user['username']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
