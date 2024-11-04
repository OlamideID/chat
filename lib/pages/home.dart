import 'package:chat/components/mydrawer.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/user_profile%20page.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final Authservice _authservice = Authservice();

  @override
  Widget build(
    BuildContext context,
  ) {
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

  _showDeleteMessage(
    BuildContext context,
    String otherUserId,
    String username,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: Text(
                'Delete Messages',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                confirmDeleteMessages(context, otherUserId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(
                'Block User',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _chatService.blockUser(otherUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You have blocked $username'),
                    behavior: SnackBarBehavior.floating,
                  ),
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

  Future<void> confirmDeleteMessages(
      BuildContext context, String otherUserID) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Messages'),
          content: const Text(
              'Are you sure you want to delete all messages? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ChatService()
                    .deleteAllMessages(otherUserID); // Call the delete function
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  viewProfile(BuildContext context, String name, String about) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserProfilePage(
          about: about,
          username: name,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  Widget _buildUser() {
    return StreamBuilder(
      stream: _chatService.getExceptBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingAnimation());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No  other users found'));
        }

        var users = snapshot.data!
            .where((userData) =>
                userData["email"] != _authservice.currentUser()?.email &&
                userData["isDeleted"] != true)
            .toList();

        if (users.isEmpty) {
          return const Center(child: Text('No other users available'));
        }

        return AnimationLimiter(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildUserItem(users[index], context),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["uid"] != _authservice.currentUser()?.uid) {
      return UserTile(
        delete: () async {
          await _showDeleteMessage(
              context, userData['uid'], userData["username"]);
        },
        text: userData["username"],
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
                ontap: () {
                  viewProfile(
                    context,
                    userData["username"] ?? '',
                    userData['about'] ?? 'No Status yet',
                  );
                },
                receiverID: userData['uid'],
                receiver: userData["username"] ?? '',
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('oops'));
    }
  }
}

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/Animation - 1730069741511.json',
              height: 100, width: 200),
        ],
      ),
    );
  }
}
