import 'dart:io';

import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Map<String, dynamic>>> getUsers() {
    return _store.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, messageContent) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message message = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: messageContent,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoom = ids.join('_');

    await _store
        .collection('chat_rooms')
        .doc(chatRoom)
        .collection('messages')
        .add(message.toMap());
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

  Future<void> updateTypingStatus(String otherUserID, bool isTyping) async {
  final String currentUserID = _auth.currentUser!.uid;

  // Sort user IDs to form a unique chat room ID
  List<String> ids = [currentUserID, otherUserID];
  ids.sort();
  String chatRoomId = ids.join('_');

  // Update the typing status in Firestore
  await _store
      .collection('chat_rooms')
      .doc(chatRoomId)
      .set({
        'isTyping': {currentUserID: isTyping},
      }, SetOptions(merge: true));
}


  Future<void> sendImage(String receiverID, File imageFile) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Generate a unique file path in Firebase Storage
    String filePath =
        'chat_images/${DateTime.now().millisecondsSinceEpoch}_$currentUserID.jpg';

    try {
      // Upload the image to Firebase Storage
      UploadTask uploadTask = _storage.ref(filePath).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Create a message object with the image URL
      Message message = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: imageUrl, // Storing the image URL as the message
        timestamp: timestamp,
      );

      // Create unique chat room ID by sorting user IDs
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoom = ids.join('_');

      // Save the image message to Firestore
      await _store
          .collection('chat_rooms')
          .doc(chatRoom)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      print("Error sending image: $e");
      throw Exception("Error sending image");
    }
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
}
