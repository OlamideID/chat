import 'dart:io';

import 'package:chat/services/profile/profile_service.dart'; // Your profile service
import 'package:file_picker/file_picker.dart'; // For web file picker
import 'package:flutter/foundation.dart'; // For `kIsWeb`
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
    profilePictureUrl = widget.profilePictureUrl;
  }

  // Upload Profile Picture (Mobile)
  Future<void> _uploadProfilePictureMobile() async {
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
        final imageUrl = await ProfilePictureService()
            .uploadProfilePicture(File(pickedFile.path));

        widget.onUpdate(imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture uploaded successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Upload Profile Picture (Web)
  Future<void> _uploadProfilePictureWeb() async {
    final filePicker = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (filePicker != null && filePicker.files.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final fileBytes = filePicker.files.first.bytes!;
        final fileName = filePicker.files.first.name;

        final imageUrl = await ProfilePictureService()
            .uploadProfilePictureWeb(fileBytes, fileName);

        widget.onUpdate(imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture uploaded successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Delete Profile Picture
  Future<void> _deleteProfilePicture() async {
    if (profilePictureUrl == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await ProfilePictureService().deleteProfilePicture(profilePictureUrl!);

      widget.onUpdate(null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture deleted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting profile picture: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // View Full Screen Image
  void _viewFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(imageUrl: profilePictureUrl),
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
                      : CircleAvatar(
                          radius: 100,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.person, size: 100),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: kIsWeb
                        ? _uploadProfilePictureWeb
                        : _uploadProfilePictureMobile,
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

// Full-Screen Image Page
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
            ? InteractiveViewer(
                child: Image.network(imageUrl!),
              )
            : const Icon(Icons.person, size: 200),
      ),
    );
  }
}
