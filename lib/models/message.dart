import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final String? imageUrl; // Optional field for image URL

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl, // Defaults to null if not provided
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'imageUrl': imageUrl, // Include imageUrl in the map
    };
  }

  // Factory constructor for creating a Message from a Firestore document
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'], // Retrieve imageUrl from the map
    );
  }
}
