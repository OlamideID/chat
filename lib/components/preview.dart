import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImagePickerPreview extends StatefulWidget {
  final File imageFile;

  const ImagePickerPreview({
    super.key,
    required this.imageFile, // Image passed from UserInputField
  });

  @override
  State<ImagePickerPreview> createState() => _ImagePickerPreviewState();
}

class _ImagePickerPreviewState extends State<ImagePickerPreview> {
  bool _isUploading = false;
  bool _uploadCompleted = false; // Track upload status

  Future<String?> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated with Firebase.');
      }

      final fileName =
          '${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage.from('Images').upload(
          fileName, imageFile,
          fileOptions: const FileOptions(upsert: true));

      final publicUrl = Supabase.instance.client.storage
          .from('Images')
          .getPublicUrl(fileName);

      setState(() {
        _isUploading = false;
        _uploadCompleted = true; // Mark upload as completed
      });
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Image upload failed: $e');
      }
      setState(() => _isUploading = false);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview & Upload Image'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          // Image container takes up the whole screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover, // Make image cover the entire container
                ),
              ),
              child: _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : null,
            ),
          ),

          // Positioned Close button
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(); // Cancel and go back
                },
              ),
            ),
          ),

          // Positioned Send button
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                if (!_isUploading && !_uploadCompleted) {
                  final imageUrl = await _uploadImage(widget.imageFile);
                  if (imageUrl != null) {
                    Navigator.of(context).pop(imageUrl); // Send image URL back
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
