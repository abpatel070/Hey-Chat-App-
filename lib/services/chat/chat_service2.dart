import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService2 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to get the list of users
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshots) {
      return snapshots.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      // Assuming you are using Firestore
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    } catch (e) {
      print('Error deleting group: $e');
      throw e; // Handle or propagate the error as needed
    }
  }


  Future<void> deleteGroupMessage(String groupId, String messageId) async {
    await _firestore
        .collection('group_messages')
        .doc(messageId)
        .delete();
  }

  // Method to create a new group
  Future<void> createGroup(List<String> userIds, String groupName) async {
    try {
      DocumentReference groupRef = await _firestore.collection('groups').add({
        'name': groupName,
        'members': userIds,
        'createdAt': FieldValue.serverTimestamp(),
      });

      String groupId = groupRef.id;

      // Update each user's group list
      for (String userId in userIds) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('groups')
            .doc(groupId)
            .set({
          'groupId': groupId,
          'groupName': groupName,
        });
      }
    } catch (e) {
      print('Error creating group: $e');
      throw e;
    }
  }

  // Stream to get the list of groups a user belongs to
  Stream<List<Map<String, dynamic>>> getGroupsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('groups')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> groups = [];
      for (var doc in snapshot.docs) {
        String groupId = doc.data()['groupId'];
        DocumentSnapshot groupDoc = await _firestore.collection('groups').doc(groupId).get();
        if (groupDoc.exists) {
          Map<String, dynamic> groupData = groupDoc.data() as Map<String, dynamic>;
          groups.add({
            'groupId': groupId,
            'groupName': groupData['name'] ?? '',
            'avatar': groupData['avatar'] ?? 'android/assets/avatar/avatar2.png',
            'memberCount': (groupData['members'] as List?)?.length ?? 0,
          });
        }
      }
      return groups;
    });
  }

  // Stream to get messages for a specific group
  Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessagesStream(String groupId) {
    return _firestore
        .collection('group_messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Method to send a message in a group
  Future<void> sendGroupMessage({
    required String groupId,
    required String message,
    required String senderName,
  }) async {
    var messageId = _firestore.collection('group_messages').doc().id;
    await _firestore.collection('group_messages').doc(messageId).set({
      'id': messageId,
      'message': message,
      'groupId': groupId,
      'senderName': senderName,
      'timestamp': Timestamp.now(),
    });
  }

  // Method to get the latest message in a chat room
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
}
