import 'package:chat/pages/profilepic.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final String? username;
  final String? about;
  final String? profilePictureUrl;

  const UserProfilePage({
    super.key,
    this.username,
    this.about,
    this.profilePictureUrl,
  });

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _usernameAnimation;
  late Animation<Offset> _aboutAnimation;
  late Animation<Offset> _profilePicAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
      vsync: this,
    );

    _usernameAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _aboutAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _profilePicAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Generates a consistent color based on the username.
  Color _getAvatarColor(String name) {
    int hash = name.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    // Provide default values for null or empty strings
    final String displayUsername = (widget.username?.trim().isNotEmpty == true)
        ? widget.username!
        : 'Anonymous User';

    final String displayAbout =
        (widget.about?.trim().isNotEmpty == true) ? widget.about! : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayUsername),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              SlideTransition(
                position: _profilePicAnimation,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Only navigate if profile picture URL is valid
                      if (widget.profilePictureUrl != null &&
                          widget.profilePictureUrl!.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenProfilePicturePage(
                              profilePicture: displayUsername,
                              profilePictureUrl: widget.profilePictureUrl!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'profilePictureHero',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: widget.profilePictureUrl == null ||
                                widget.profilePictureUrl!.trim().isEmpty
                            ? _getAvatarColor(displayUsername)
                            : Theme.of(context).colorScheme.secondary,
                        backgroundImage: widget.profilePictureUrl != null &&
                                widget.profilePictureUrl!.trim().isNotEmpty
                            ? NetworkImage(widget.profilePictureUrl!)
                            : null,
                        child: widget.profilePictureUrl == null ||
                                widget.profilePictureUrl!.trim().isEmpty
                            ? Text(
                                displayUsername.isNotEmpty
                                    ? displayUsername[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 36,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Username Section
              SlideTransition(
                position: _usernameAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayUsername,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // About Section
              SlideTransition(
                position: _aboutAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          displayAbout,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
