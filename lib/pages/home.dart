import 'package:chat/components/mydrawer.dart';
import 'package:chat/components/user_tile.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/user_profile%20page.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:chat/services/auth/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

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
  bool _isSearchActive = false; // Track if the search bar is active

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reset the search bar when coming back to the HomePage
    if (!_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      setState(() {
        _isSearchActive = false; // Set search bar to inactive
        _searchQuery = ''; // Clear search query
        _searchController.clear(); // Clear search input
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: AnimatedSwitcher(
          duration: const Duration(
              milliseconds: 500), // Adjusted duration for smoother transition
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Use a smooth fade and scale transition
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _isSearchActive
              ? Container(
                  key: ValueKey<bool>(_isSearchActive),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    },
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                )
              : Text(
                  'HOME',
                  key: ValueKey<bool>(_isSearchActive),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchFocusNode.unfocus();
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: _buildUser(),
      drawer: const Mydrawer(),
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
          ).then((_) {
            return ();
          });
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
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/Animation - 1730069741511.json',
        height: 150, width: 150);
  }
}
