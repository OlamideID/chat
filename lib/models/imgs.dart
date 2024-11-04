import 'package:cloud_firestore/cloud_firestore.dart';

class ImgMessage {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String messageType;  // 'text' or 'image'

  ImgMessage({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.messageType,
  });

  // Converts an ImgMessage object to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType,
    };
  }

  // Factory constructor to create an ImgMessage object from Firestore data
  factory ImgMessage.fromMap(Map<String, dynamic> map) {
    return ImgMessage(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'],
      timestamp: map['timestamp'],
      messageType: map['messageType'],
    );
  }
}
