import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  Future<void> _sendImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      // Return the image file back to the calling screen
      Navigator.of(context).pop(imageFile);
    } catch (e) {
      if (kDebugMode) {
        print('Image processing failed: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process the image: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
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
                  fit: BoxFit.cover, // Keep original design
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
                if (!_isUploading) {
                  await _sendImage(widget.imageFile);
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
