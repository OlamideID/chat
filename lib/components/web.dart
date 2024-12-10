import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WebImagePickerPreview extends StatelessWidget {
  final XFile imageFile;

  const WebImagePickerPreview({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              final Uint8List imageBytes = await imageFile.readAsBytes();
              Navigator.pop(context, imageBytes);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageFile.path,
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
            const SizedBox(height: 20),
            Text('Selected Image: ${imageFile.name}')
          ],
        ),
      ),
    );
  }
}
