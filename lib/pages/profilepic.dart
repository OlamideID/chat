import 'package:cached_network_image/cached_network_image.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'profilePictureHero',
          child: InteractiveViewer(
            maxScale: 5.0,
            child: CachedNetworkImage(
              imageUrl: profilePictureUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 50,
              ),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
