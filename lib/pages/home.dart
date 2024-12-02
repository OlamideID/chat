import 'package:chat/components/loading.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/pages/blocked2.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/user_profile%20page.dart';
// import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, RouteAware {
  final ChatService _chatService = ChatService();
  final Authservice _authservice = Authservice();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
// State to control AppBar visibility

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    _searchFocusNode.unfocus();
    super.dispose();
  }

  String _selectedTab = 'Users';

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer, // Updated color
                  radius: 18,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Hide AppBar if _isAppBarVisible is false
      body: GestureDetector(
        onTap: () {
          // Show AppBar when user interacts with the body
          setState(() {});
        },
        child: Column(
          children: [
            // Users and Blocked Tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Users Tab
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Users';
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Users',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 'Users'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.black12,
                        thickness: 1,
                        width: 20,
                        indent: 4,
                        endIndent: 4,
                      ),
                      // Blocked Tab
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Blocked';
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Blocked',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 'Blocked'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Display the selected tab's content
            Expanded(
              child: _selectedTab == 'Users'
                  ? _buildUser()
                  : Blocked2(const TextStyle()),
            ),
          ],
        ),
      ),
    );
  }

  _showDeleteMessage(
      BuildContext context, String otherUserId, String username) {
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ChatService().deleteAllMessages(otherUserID);
                Navigator.of(context).pop();
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
          return const Center(child: Text('No other users found'));
        }

        var users = snapshot.data!
            .where((userData) =>
                userData["email"] != _authservice.currentUser()?.email &&
                userData["isDeleted"] != true)
            .toList();

        // Apply the search query filter
        if (_searchQuery.isNotEmpty) {
          users = users.where((userData) {
            return userData["username"]
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (users.isEmpty) {
          return const Center(child: Text('No matching users found'));
        }

        return AnimationLimiter(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final slideDirection = index.isEven
                  ? const Offset(1.0, 0.0)
                  : const Offset(-1.0, 0.0);

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: slideDirection.dx * 50.0,
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

  // Stream to listen for real-time updates
  Stream<String> _getLastMessageFromChatroom(String otherUserId) {
    String? currentUserId = _authservice.currentUser()?.uid;
    if (currentUserId == null) {
      return Stream.value(
          ''); // Return an empty stream if there's no current user
    }

    // Generate the chatroom ID (sorted to ensure consistency)
    String chatroomId = _generateChatroomId(currentUserId, otherUserId);

    // Stream the last message from Firestore in real-time
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var lastMessageData = snapshot.docs.first.data();
        return lastMessageData['message'] ?? '';
      }
      return ''; // Return empty if no message
    });
  }

  // Utility method to generate a consistent chatroom ID
  String _generateChatroomId(String user1Id, String user2Id) {
    List<String> sortedIds = [user1Id, user2Id]..sort();
    return sortedIds.join('_');
  }

  Stream<int> getMessageCount(String otherUserId) {
    // Get the current user's ID
    String? currentUserId = _authservice.currentUser()?.uid;

    if (currentUserId == null) {
      print("No current user found");
      return Stream.value(0);
    }

    String chatroomId = _generateChatroomId(currentUserId, otherUserId);

    print("Chatroom ID: $chatroomId for otherUserId: $otherUserId");

    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderID', isEqualTo: otherUserId)
        .snapshots()
        .map((snapshot) {
      print("Unread messages count: ${snapshot.docs.length}");
      for (var doc in snapshot.docs) {
        print("Message Data: ${doc.data()}");
      }
      return snapshot.docs.length;
    });
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    // Check if this is not the current user
    if (userData["uid"] != _authservice.currentUser()?.uid) {
      return StreamBuilder<int>(
        stream: getMessageCount(userData['uid']), // Use getMessageCount here
        builder: (context, countSnapshot) {
          return StreamBuilder<String>(
            stream: _getLastMessageFromChatroom(userData['uid']),
            builder: (context, snapshot) {
              return UserTile(
                count: countSnapshot.data ??
                    0, // Pass the unread message count to UserTile
                initial: userData["username"]?.isNotEmpty ?? false
                    ? userData["username"]![0]
                        .toUpperCase() // First letter of username
                    : '', // If username is empty, display nothing
                text: userData["username"] ?? '',
                lastMessage: snapshot.data ?? '',
                delete: () async {
                  await _showDeleteMessage(
                      context, userData['uid'], userData["username"]);
                },
                onTap: () {
                  _searchFocusNode.unfocus();

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ChatPage(
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
            },
          );
        },
      );
    } else {
      return const Center(child: Text('oops'));
    }
  }
}
