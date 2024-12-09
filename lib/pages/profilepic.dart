import 'package:flutter/material.dart';

class FullScreenProfilePicturePage extends StatelessWidget {
  final String profilePictureUrl;
  final String profilePicture;

  const FullScreenProfilePicturePage({
    super.key,
    required this.profilePictureUrl,
    required this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profilePicture),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Hero(
          tag: 'profilePictureHero',
          child: Image.network(
            profilePictureUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
