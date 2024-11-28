import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverID;
  final String message; // This can be a text message or a description of the file
  final String? fileUrl; // Optional field for file URLs
  final Timestamp timestamp;
  final bool read;
  final String? imageUrl; // Optional field for image URLs

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    this.fileUrl, // Optional field for file URLs
    required this.timestamp,
    required this.read,
    this.imageUrl, // Optional field for image URLs
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'fileUrl': fileUrl, // Include file URL in the map
      'timestamp': timestamp,
      'read': read,
      'imageUrl': imageUrl, // Include image URL in the map
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] as String,
      senderEmail: map['senderEmail'] as String,
      receiverID: map['receiverID'] as String,
      message: map['message'] as String,
      fileUrl: map['fileUrl'] as String?, // Handle nullable field
      timestamp: map['timestamp'] as Timestamp,
      read: map['read'] ?? false,
      imageUrl: map['imageUrl'] as String?, // Handle nullable field
    );
  }
}
