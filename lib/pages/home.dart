import 'package:chat/components/loading.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/pages/blocked2.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/user_profile%20page.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  // final Set<String> _recentlyViewedChats = {};
  static String? _currentOpenChatId;

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
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(_authservice.currentUser()?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final profilePictureUrl = userData?['profilePicture'];

                      return CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        radius: 18,
                        child: profilePictureUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  profilePictureUrl,
                                  fit: BoxFit.cover,
                                  width: 36,
                                  height: 36,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                      );
                    }

                    // Fallback to default icon while loading
                    return CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      radius: 18,
                      child: Icon(
                        Icons.person,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    );
                  },
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

  _showOptions(BuildContext context, String otherUserId, String username) {
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

  void _markMessagesAsRead(String otherUserId) async {
    // Get the current user's ID
    String? currentUserId = _authservice.currentUser()?.uid;

    if (currentUserId == null) {
      if (kDebugMode) {
        print("No current user found");
      }
      return;
    }

    String chatroomId = _generateChatroomId(currentUserId, otherUserId);

    // Query for unread messages from the other user
    QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderID', isEqualTo: otherUserId)
        .get();

    // Batch update to mark messages as read
    if (unreadMessages.docs.isNotEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Commit the batch
      await batch.commit();
    }
  }

  Stream<int> getMessageCount(String otherUserId) {
    String? currentUserId = _authservice.currentUser()?.uid;

    // Don't show count if this is the current open chat
    if (currentUserId == null || otherUserId == _currentOpenChatId) {
      return Stream.value(0);
    }

    String chatroomId = _generateChatroomId(currentUserId, otherUserId);

    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .where('isRead', isEqualTo: false) // Only unread messages
        .where('senderID',
            isEqualTo: otherUserId) // Messages from the other user
        .snapshots()
        .map((snapshot) {
      // Count unread messages
      if (snapshot.docs.isNotEmpty) {
        // If new messages come in while the chat is open, mark them as read
        if (_currentOpenChatId == otherUserId) {
          _markMessagesAsRead(
              otherUserId); // Call the method to mark messages as read
        }
      }
      return snapshot.docs.length;
    });
  }

  Stream<void> listenForNewMessages(String otherUserId) {
    String? currentUserId = _authservice.currentUser()?.uid;

    if (currentUserId == null) {
      return const Stream.empty();
    }

    String chatroomId = _generateChatroomId(currentUserId, otherUserId);

    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      // If the current chat is open, mark messages as read
      if (_currentOpenChatId == otherUserId) {
        _markMessagesAsRead(otherUserId);
      }
    });
  }

  Stream<String?> _getProfilePictureStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users') // Replace with your user collection
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        return userData['profilePicture']
            as String?; // Replace with actual field name
      }
      return null; // If the document doesn't exist, return null
    });
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    return StreamBuilder<void>(
      stream: listenForNewMessages(userData['uid']),
      builder: (context, snapshot) {
        return StreamBuilder<int>(
          stream: getMessageCount(userData['uid']),
          builder: (context, countSnapshot) {
            return StreamBuilder<String>(
              stream: _getLastMessageFromChatroom(userData['uid']),
              builder: (context, lastMessageSnapshot) {
                return StreamBuilder<String?>(
                  stream: _getProfilePictureStream(userData['uid']),
                  builder: (context, profilePictureSnapshot) {
                    String? profilePictureUrl = profilePictureSnapshot.data;

                    return Slidable(
                      endActionPane:
                          ActionPane(motion: const StretchMotion(), children: [
                        SlidableAction(
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            _chatService.blockUser(userData['uid']);
                          },
                          backgroundColor: Colors.blue,
                          icon: Icons.block,
                        ),
                        SlidableAction(
                          padding: const EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            await confirmDeleteMessages(
                                context, userData['uid']);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                        ),
                      ]),
                      child: UserTile(
                        count: countSnapshot.data ?? 0,
                        initial: userData["username"]?.isNotEmpty ?? false
                            ? userData["username"]![0].toUpperCase()
                            : '',
                        text: userData["username"] ?? '',
                        lastMessage: lastMessageSnapshot.data ?? '',
                        delete: () async {
                          await _showOptions(
                              context, userData['uid'], userData["username"]);
                        },
                        onTap: () {
                          setState(() {
                            _currentOpenChatId = userData['uid'];
                          });

                          _markMessagesAsRead(userData['uid']);

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ChatPage(
                                ontap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(
                                            profilePictureUrl: profilePictureUrl,
                                            username: userData['username'],
                                            about: userData['about']),
                                      ));
                                },
                                receiverProfilePicUrl: profilePictureUrl,
                                receiverID: userData['uid'],
                                receiver: userData["username"] ?? '',
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                            ),
                          ).then((_) {
                            setState(() {
                              _currentOpenChatId = null;
                            });
                          });
                        },
                        // Pass the profile picture URL to the UserTile
                        profilePictureUrl: profilePictureUrl,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
