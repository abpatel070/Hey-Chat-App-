import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupDetailsPage({
    required this.groupId,
    required this.groupName,
  });

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getGroupMembers(String groupId) async {
    try {
      // Fetch the group document from Firestore
      DocumentSnapshot groupDoc =
      await _firestore.collection('groups').doc(groupId).get();

      if (groupDoc.exists) {
        // Extract the members array
        List<dynamic> memberIds = groupDoc['members'];

        // Fetch the details for each member
        List<Map<String, dynamic>> memberDetails = [];
        for (var userId in memberIds) {
          DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            // Add each user's name and email to the list
            memberDetails.add({
              'name': userData['name'] ?? 'No Name',
              //'email': userData['email'] ?? 'No Email',
            });
          }
        }
        return memberDetails;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching group members: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getGroupMembers(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No members found in this group.'));
          }

          // Get the member details
          List<Map<String, dynamic>> members = snapshot.data!;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              var member = members[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(member['name'] ?? 'No Name'),
                subtitle: Text(member['email'] ?? 'No Email'),
              );
            },
          );
        },
      ),
    );
  }
}
