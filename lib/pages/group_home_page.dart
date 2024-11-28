import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/services/chat/chat_service2.dart';
import 'package:hey2/pages/group_chat_page.dart';
import 'package:hey2/utils/user_utils.dart';

class GroupHomePage extends StatefulWidget {
  GroupHomePage({Key? key}) : super(key: key);

  @override
  _GroupHomePageState createState() => _GroupHomePageState();
}

class _GroupHomePageState extends State<GroupHomePage> {
  final ChatService2 _chatService2 = ChatService2();
  final AuthService _authService = AuthService();

  Future<String?> _fetchCurrentUserName() async {
    return await getCurrentUserName(); // Fetch the current user's name
  }

  Future<void> _showDeleteConfirmationDialog(String groupId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Group'),
          content: Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _chatService2.deleteGroup(groupId); // Delete group from database
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[500],
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        toolbarHeight: 80,
        title: Text(
          'Groups',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _authService.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return Center(child: Text("Error: ${userSnapshot.error}"));
          }

          if (!userSnapshot.hasData) {
            return const Center(child: Text("No user data available"));
          }

          User? currentUser = userSnapshot.data;

          return FutureBuilder<String?>(
            future: _fetchCurrentUserName(), // Fetch the current user's name
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (nameSnapshot.hasError) {
                return Center(child: Text("Error: ${nameSnapshot.error}"));
              }

              if (!nameSnapshot.hasData) {
                return const Center(child: Text("No user name available"));
              }

              String currentUserName = nameSnapshot.data!;

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatService2.getGroupsStream(currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Map<String, dynamic>> groups = snapshot.data ?? [];

                  if (groups.isEmpty) {
                    return const Center(child: Text("No groups available"));
                  }

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      var groupData = groups[index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('android/assets/icon/gp1.png'),
                        ),
                        title: Text(groupData["groupName"] ?? 'Unnamed Group'),
                        subtitle: Text('Members: ${groupData["memberCount"] ?? 0}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(groupData["groupId"] ?? '');
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatPage(
                                groupId: groupData["groupId"] ?? '',
                                groupName: groupData["groupName"] ?? 'Unnamed Group',
                                senderName: currentUserName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}