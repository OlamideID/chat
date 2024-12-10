import 'dart:io';

import 'package:chat/components/preview.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/components/web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInputField extends StatefulWidget {
  final Function(String message) onSendMessage;
  final Function(dynamic imageFile) onSendImage;

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
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        dynamic result;
        if (kIsWeb) {
          // For web
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebImagePickerPreview(imageFile: pickedFile),
            ),
          );
        } else {
          // For mobile
          result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePickerPreview(
                imageFile: File(pickedFile.path),
              ),
            ),
          );
        }

        if (result != null) {
          // Directly call the onSendImage handler here
          widget.onSendImage(result);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 20),
          child: Row(
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.blue[700],
                ),
                onPressed: _pickImage,
              ),
              Expanded(
                child: MyTextField(
                  maxLines: null,
                  controller: _messageController,
                  hintText: 'Type a message...',
                  obscure: false,
                  onChanged: (text) {
                    setState(() {});
                  },
                  onTap: () {},
                  keyboardtype: TextInputType.text,
                ),
              ),
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
}
