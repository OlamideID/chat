import 'package:chat/components/mydrawer.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/user_profile%20page.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final Authservice _authservice = Authservice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Home'),
      ),
      body: _buildUser(),
      drawer: const Mydrawer(),
    );
  }

  viewProfile(BuildContext context, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfilePage(username: name)),
    );
  }

  Widget _buildUser() {
    return StreamBuilder(
      stream: _chatService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              children: [Text('Loading'), CircularProgressIndicator()],
            ),
          );
        }

        // Ensure snapshot has data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        // Filter out deleted or inactive accounts
        var users = snapshot.data!
            .where((userData) =>
                userData["email"] != _authservice.currentUser()?.email &&
                userData["isDeleted"] !=
                    true) // Adjust if you track deleted status
            .toList();

        if (users.isEmpty) {
          return const Center(child: Text('No other users available'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserItem(users[index], context);
          },
        );
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["uid"] != _authservice.currentUser()?.uid) {
      return InkWell(
        child: UserTile(
          text: userData["username"],
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    ontap: () {
                      viewProfile(context, userData["username"] ?? '');
                    },
                    receiverID: userData['uid'],
                    receiver: userData["username"] ?? '',
                  ),
                ));
          },
        ),
      );
    } else {
      return const Center(child: Text('oops'));
    }
  }
}
