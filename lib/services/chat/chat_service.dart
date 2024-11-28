import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';  // Import Firebase Storage
import 'package:hey2/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;  // Initialize Firebase Storage

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore
        .collection("Users")
        .snapshots()
        .asyncMap((snapshots) async {
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshots.docs) {
        final user = doc.data();
        if (await _hasMessages(user['uid'])) {
          users.add(user);
        }
      }
      return users;
    });
  }

  Future<void> deleteUserAndChats(String userId) async {
    try {
      String currentUserId = _auth.currentUser!.uid;
      List<String> ids = [currentUserId, userId];
      ids.sort();
      String chatRoomId = ids.join('_');

      DocumentReference chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

      QuerySnapshot messages = await chatRoomRef.collection('messages').get();

      WriteBatch batch = _firestore.batch();

      for (DocumentSnapshot message in messages.docs) {
        batch.delete(message.reference);
      }

      await batch.commit();

      print('Messages deleted for chat room: $chatRoomId');
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final snapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<int> getUnreadMessageCount(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return 0;

    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    try {
      final snapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('Users').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<bool> _hasMessages(String userId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    List<String> ids = [currentUserId, userId];
    ids.sort();
    String chatRoomId = ids.join('_');

    QuerySnapshot messagesSnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .limit(1)
        .get();

    return messagesSnapshot.docs.isNotEmpty;
  }

  Future<void> sendMessage(String receiverID, String message, String senderId, {String? imageUrl}) async {
    final String currentUserId = senderId;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      imageUrl: imageUrl,  // Include imageUrl in message
      read: false, // Set initial read status to false
    );

    List<String> ids = [currentUserId, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserId) {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<DocumentSnapshot> getMessage(String userID, String otherUserId, String messageId) async {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    return await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageId)
        .get();
  }

  Future<void> deleteMessage(String userID, String otherUserId, String messageId) async {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  Future<void> deleteMessages(String userId, String otherUserId, Set<String> messageIds) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    WriteBatch batch = _firestore.batch();

    for (var messageId in messageIds) {
      batch.delete(
        _firestore
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .doc(messageId),
      );
    }

    await batch.commit();
  }

  Future<String> getLatestMessage(String userID, String otherUserId) async {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    QuerySnapshot snapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return ''; // No messages
    }

    var latestMessage = snapshot.docs.first.data() as Map<String, dynamic>;
    String content = latestMessage['message'] ?? '';
    String senderId = latestMessage['senderId'];
    String currentUserId = _auth.currentUser?.uid ?? '';

    return senderId == currentUserId ? "You: $content" : content;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = _storage.ref().child("chat_images/$fileName");
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }
}
