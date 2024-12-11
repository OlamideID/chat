import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePictureService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;

      // Prepare the file for upload
      final String fileName =
          '${currentUserID}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'ProfilePictures/$fileName';

      // Upload image to Supabase
      await Supabase.instance.client.storage
          .from('ProfilePictures')
          .upload(filePath, imageFile);

      // Generate the public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('ProfilePictures')
          .getPublicUrl(filePath);

      // Update Firestore with the new profile picture URL
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserID)
          .update({
        'profilePicture': imageUrl,
      });

      if (kDebugMode) {
        print('Profile picture uploaded successfully with URL: $imageUrl');
      }

      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile picture: $e');
      }
      rethrow;
    }
  }

  Future<String?> uploadProfilePictureWeb(Uint8List fileBytes, String fileName) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;

      // Generate a unique file name
      final String uniqueFileName =
          '${currentUserID}_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String filePath = 'ProfilePictures/$uniqueFileName';

      // Upload file bytes to Supabase
      await Supabase.instance.client.storage
          .from('ProfilePictures')
          .uploadBinary(filePath, fileBytes);

      // Generate the public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('ProfilePictures')
          .getPublicUrl(filePath);

      // Update Firestore with the new profile picture URL
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserID)
          .update({
        'profilePicture': imageUrl,
      });

      if (kDebugMode) {
        print('Profile picture uploaded successfully with URL: $imageUrl');
      }

      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile picture on web: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteProfilePicture(String? profilePictureUrl) async {
    if (profilePictureUrl == null) return;

    try {
      final currentUserID = _auth.currentUser!.uid;

      // Extract file name from URL
      final fileName = profilePictureUrl.split('/').last;
      final filePath = 'ProfilePictures/$fileName';

      // Delete from Supabase storage
      await Supabase.instance.client.storage
          .from('ProfilePictures')
          .remove([filePath]);

      // Update Firestore to remove profile picture URL
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserID)
          .update({
        'profilePicture': FieldValue.delete(),
      });

      if (kDebugMode) {
        print('Profile picture deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile picture: $e');
      }
      rethrow;
    }
  }
}
