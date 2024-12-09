import 'dart:io';

import 'package:chat/components/preview.dart';
import 'package:chat/components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInputField extends StatefulWidget {
  final Function(String message) onSendMessage;
  final Function(File imageFile) onSendImage;

  const UserInputField({
    super.key,
    required this.onSendMessage,
    required this.onSendImage,
  });

  @override
  State<UserInputField> createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _getImage();
    if (pickedImage != null) {
      // Navigate to the ImagePickerPreview screen
      final imageUrl = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePickerPreview(imageFile: pickedImage),
        ),
      );

      if (imageUrl != null) {
        // Handle the image URL after successful upload
        widget.onSendImage(pickedImage); // Send the image file to parent widget
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input Field Section
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 20),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              // Image Picker Icon
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.blue[700],
                ),
                onPressed: _pickImage, // Trigger image picker and navigation
              ),

              // Use Textfield2 for message input
              Expanded(
                child: MyTextField(
                  maxLines: null,
                  controller: _messageController,
                  hintText: 'Type a message...',
                  obscure: false,
                  onChanged: (text) {
                    setState(() {}); // Update UI for send button
                  },
                  onTap: () {},
                  keyboardtype: TextInputType.text,
                ),
              ),

              // Send Button (visible only when text is entered)
              if (_messageController.text.trim().isNotEmpty)
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Pick image function using ImagePicker package
  Future<File?> _getImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
