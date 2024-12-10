import 'dart:io';

import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import the image package

class ChatService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsers() {
    return _store.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendImageMessage(String receiverID, dynamic imageFile) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    try {
      // Validate image file
      if (imageFile == null) {
        throw Exception('Image file cannot be null');
      }

      // Prepare the file for upload
      final String fileName =
          '${currentUserID}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'Images/$fileName';

      // Handle different file types for web and mobile
      if (kIsWeb) {
        // For web, expect Uint8List
        if (imageFile is! Uint8List) {
          throw Exception('Web image must be Uint8List');
        }
        // Upload for web
        await Supabase.instance.client.storage.from('Images').uploadBinary(
              filePath,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        // For mobile, expect File
        if (imageFile is! File) {
          throw Exception('Mobile image must be File');
        }
        // Upload for mobile
        await Supabase.instance.client.storage.from('Images').upload(
              filePath,
              imageFile,
              fileOptions: FileOptions(upsert: true),
            );
      }

      // Generate the public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('Images')
          .getPublicUrl(filePath);

      // Validate URL
      if (imageUrl.isEmpty) {
        throw Exception('Image URL generation failed');
      }

      // Construct the message object
      final message = {
        'senderID': currentUserID,
        'senderEmail': currentUserEmail,
        'receiverID': receiverID,
        'message': '', // Image message without text
        'timestamp': timestamp,
        'isRead': false,
        'imageUrl': imageUrl,
      };

      // Generate chat room ID
      final List<String> ids = [currentUserID, receiverID]..sort();
      final String chatRoomId = ids.join('_');

      // Save to Firestore
      await _store
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);

      if (kDebugMode) {
        print('Image message sent successfully with URL: $imageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending image message: $e');
      }
      rethrow;
    }
  }

  Future<void> sendMessage(String receiverID,
      {required String message, String? imageUrl}) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    try {
      // Construct the message object
      final newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        isRead: false,
        imageUrl: imageUrl ?? '', // Add image URL if provided
      );

      // Generate chat room ID
      final List<String> ids = [currentUserID, receiverID]..sort();
      final String chatRoomId = ids.join('_');

      // Save to Firestore
      await _store
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      if (kDebugMode) {
        print('Message sent successfully with image URL: $imageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteMessage(
      String messageId, String userID, String otherUserID) async {
    try {
      // Ensure user IDs are sorted to generate a consistent chat room ID
      List<String> ids = [userID, otherUserID];
      ids.sort();
      String chatRoomId = ids.join('_');

      // Reference to the specific message document
      DocumentReference messageRef = _store
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      // Mark the message as deleted by updating the 'isDeleted' field
      await messageRef.update({
        'isDeleted': true, // Flag the message as deleted
      });

      print("Message $messageId marked as deleted successfully.");
    } catch (e) {
      print("Error marking message as deleted: $e");
      throw Exception("Error marking message as deleted");
    }
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _store
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> reportUser(String messageId, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _store.collection('reports').add(report);
  }

  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;

    // Add the user to the BlockedUsers sub-collection with a timestamp
    await _store
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({
      'blockedby': currentUser.uid,
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _store
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserID)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUsers(String userId) {
    return _store
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUser = snapshot.docs.map((doc) => doc.id).toList();
      final userDocs = await Future.wait(
          blockedUser.map((id) => _store.collection('Users').doc(id).get()));

      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getExceptBlocked() {
    final currentUser = _auth.currentUser;

    return _store
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUsers = snapshot.docs.map((doc) => doc.id).toList();
      final userSnapshot = await _store.collection('Users').get();

      return userSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUsers.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  Future<void> deleteAllMessages(String otherUserID) async {
    try {
      // Get the current user ID
      final String currentUserID = _auth.currentUser!.uid;

      // Generate unique chat room ID by sorting user IDs
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String chatRoomId = ids.join('_');

      // Get a reference to the messages collection within the chat room
      CollectionReference messagesRef = _store
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages');

      // Retrieve all messages in the chat room
      QuerySnapshot messagesSnapshot = await messagesRef.get();

      // Check if there are messages to delete
      if (messagesSnapshot.docs.isEmpty) {
        print(
            "No messages found to delete between $currentUserID and $otherUserID.");
        return; // Exit if no messages are found
      }

      // Create a batch to delete messages
      WriteBatch batch = _store.batch();

      for (DocumentSnapshot messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }

      // Commit the batch delete operation
      await batch.commit();
      print(
          "All messages deleted successfully between users $currentUserID and $otherUserID");

      // Optional: Remove any additional references related to the chat if needed
      // For example, if you have a record of the last message or chat status,
      // you might want to delete or update that as well.
      await _removeChatReference(chatRoomId);
    } catch (e) {
      print("Error deleting messages: $e");
      throw Exception("Error deleting messages");
    }
  }

  Future<void> _removeChatReference(String chatRoomId) async {
    // Optionally delete or update any references related to the chat room
    DocumentReference chatRef = _store.collection('chat_rooms').doc(chatRoomId);

    // Here you might choose to delete the chat room entirely or just update it
    // Example:
    await chatRef.delete(); // To delete the entire chat room
    // Or you could update the last message or chat status if applicable
    // await chatRef.update({'lastMessage': '', 'updatedAt': FieldValue.serverTimestamp()});

    print("Chat reference for $chatRoomId updated/removed.");
  }
}
