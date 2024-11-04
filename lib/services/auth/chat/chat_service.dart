import 'dart:io';

import 'package:chat/models/imgs.dart';
import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img; // Import the image package

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

  Future<void> sendImage(String receiverID, File imageFile) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Compress the image
      final originalImageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(originalImageBytes);
      img.Image resizedImage =
          img.copyResize(originalImage!, width: 800); // Resize as needed

      // Encode the resized image as JPEG with a quality parameter (0-100)
      final compressedImageBytes =
          img.encodeJpg(resizedImage, quality: 70); // Adjust quality as needed
      final compressedImageFile = File('${imageFile.path}_compressed.jpg');
      await compressedImageFile.writeAsBytes(compressedImageBytes);

      // Generate a unique file path in Firebase Storage
      String filePath =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}_$currentUserID.jpg';

      // Upload the compressed image
      UploadTask uploadTask =
          _storage.ref(filePath).putFile(compressedImageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Create an ImgMessage object with the image URL
      ImgMessage imgMessage = ImgMessage(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: imageUrl, // Storing the image URL as the message
        timestamp: timestamp,
        messageType: 'image', // Specify message type
      );

      // Save the image message to Firestore
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoom = ids.join('_');
      await _store
          .collection('chat_rooms')
          .doc(chatRoom)
          .collection('messages')
          .add(imgMessage.toMap());
    } catch (e) {
      print("Error sending image: $e");
      throw Exception("Error sending image");
    }
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
