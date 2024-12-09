import 'dart:io';

import 'package:chat/services/profile/profile_service.dart'; // Import your profile service
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore data fetching
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePage extends StatefulWidget {
  final String? profilePictureUrl;
  final Function(String? updatedUrl) onUpdate;

  const ProfilePicturePage({
    super.key,
    required this.profilePictureUrl,
    required this.onUpdate,
  });

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  bool isLoading = false;
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  // Method to fetch profile picture from Firestore
  Future<void> _loadProfilePicture() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the current user ID (Firebase Authentication)
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          String? fetchedUrl = data[
              'profilePicture']; // Assuming 'profilePicture' is the field name

          setState(() {
            profilePictureUrl = fetchedUrl ?? widget.profilePictureUrl;
          });
        }
      }
    } catch (e) {
      setState(() {
        profilePictureUrl = widget.profilePictureUrl;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle uploading the profile picture
  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Upload the selected picture to your storage service
        final imageUrl = await ProfilePictureService()
            .uploadProfilePicture(File(pickedFile.path));

        setState(() {
          isLoading = false;
        });

        // Update the profile picture in the parent page immediately
        widget.onUpdate(imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture uploaded successfully')),
        );

        // Delay for 3 seconds and close the screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      }
    }
  }

  // Function to handle deleting the profile picture
  Future<void> _deleteProfilePicture() async {
    if (profilePictureUrl == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Delete the profile picture from your storage service
      await ProfilePictureService().deleteProfilePicture(profilePictureUrl!);

      setState(() {
        isLoading = false;
      });

      // Update the profile picture URL to null in the parent page
      widget.onUpdate(null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture deleted successfully')),
      );

      // Delay for 3 seconds and close the screen
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting profile picture: $e')),
      );
    }
  }

  // Navigate to full-screen view of the image
  void _viewFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          imageUrl: profilePictureUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Picture"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profilePictureUrl != null
                      ? GestureDetector(
                          onTap: _viewFullScreenImage,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(profilePictureUrl!),
                          ),
                        )
                      : GestureDetector(
                          onTap: _uploadProfilePicture,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: const Icon(
                              Icons.person,
                              size: 100,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _uploadProfilePicture,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Picture"),
                  ),
                  const SizedBox(height: 10),
                  if (profilePictureUrl != null)
                    ElevatedButton.icon(
                      onPressed: _deleteProfilePicture,
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      label: const Text("Delete Picture"),
                    ),
                ],
              ),
            ),
    );
  }
}

// Full Screen Image Page
class FullScreenImagePage extends StatelessWidget {
  final String? imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Picture"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: imageUrl != null
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  child: Image.network(imageUrl!),
                ),
              )
            : const Center(child: Icon(Icons.person, size: 200)),
      ),
    );
  }
}
