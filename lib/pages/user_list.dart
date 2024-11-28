import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hey2/pages/user_title2.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/services/chat/chat_service2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey2/pages/chat_page.dart';
import 'package:hey2/pages/group_home_page.dart';

class UserListPage extends StatefulWidget {
  UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ChatService2 _chatService2 = ChatService2();
  final AuthService _authService = AuthService();
  bool _isSearching = false;
  bool _isSelecting = false;
  List<String> _selectedUserIds = [];
  TextEditingController _searchController = TextEditingController();
  final Random _random = Random();
  final List<String> _avatarPaths = [
    'android/assets/avatar/avatar2.png',
    'android/assets/avatar/avatar3.png',
    'android/assets/avatar/avatar6.png',
    'android/assets/avatar/avatar7.png',
    'android/assets/avatar/avatar10.png',
    'android/assets/avatar/avatar11.png',
    'android/assets/avatar/avatar12.png',
    'android/assets/avatar/avatar13.png',
  ];

  // Method to get a random avatar path ensuring uniqueness
  String _getUniqueAvatarPath(Set<String> usedAvatars) {
    if (usedAvatars.length == _avatarPaths.length) {
      throw Exception("All avatars have been used.");
    }

    String avatarPath;
    do {
      avatarPath = _avatarPaths[_random.nextInt(_avatarPaths.length)];
    } while (usedAvatars.contains(avatarPath));

    usedAvatars.add(avatarPath);
    return avatarPath;
  }

  Future<User?> _getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<String> _getLatestMessage(String otherUserId) async {
    User? currentUser = await _authService.getCurrentUser();
    if (currentUser == null) {
      return 'No messages available';
    }
    return await _chatService2.getLatestMessage(currentUser.uid, otherUserId);
  }

  void _onUserTap(String userId) {
    if (_isSelecting) {
      _toggleUserSelection(userId);
    } else {
      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverEmail: userId,
            receiverId: userId,
          ),
        ),
      );
    }
  }

  void _onUserLongPress(String userId) {
    setState(() {
      _isSelecting = true;
      _toggleUserSelection(userId);
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
        if (_selectedUserIds.isEmpty) {
          _isSelecting = false;
        }
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _createGroup() async {
    if (_selectedUserIds.isNotEmpty) {
      String? groupName = await _showGroupNameDialog();
      if (groupName != null && groupName.isNotEmpty) {
        // Call your ChatService2 to create the group with the selected users and the provided name
        await _chatService2.createGroup(_selectedUserIds, groupName);

        // Show toast message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group is created successfully')),
        );

        // Navigate to GroupHomePage after successful group creation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GroupHomePage()),
        );

        // Reset selection state
        setState(() {
          _isSelecting = false;
          _selectedUserIds.clear();
        });
      }
    }
  }

  Future<String?> _showGroupNameDialog() {
    TextEditingController _groupNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Group Name'),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(hintText: 'Group Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_groupNameController.text);
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
        title: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isSearching ? '' : 'Users',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_isSelecting)
                  IconButton(
                    icon: Icon(Icons.group_add, color: Colors.white),
                    onPressed: _createGroup,
                  ),
                if (!_isSelecting)
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: _isSearching
                      ? MediaQuery.of(context).size.width - 30
                      : 0.0,
                  height: 40.0,
                  margin: EdgeInsets.only(
                      left: _isSearching
                          ? 0
                          : MediaQuery.of(context).size.width - 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<User?>(
        future: _getCurrentUser(),
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

          return StreamBuilder(
            stream: _chatService2.getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return const Center(child: Text("No users available"));
              }

              List<Map<String, dynamic>> users = (snapshot.data as List)
                  .where((element) => element != null)
                  .map((element) => element as Map<String, dynamic>)
                  .toList();

              // Keep track of used avatars to ensure uniqueness
              Set<String> usedAvatars = {};

              return ListView(
                padding: EdgeInsets.zero,
                children: users
                    .where((userData) =>
                userData["email"] != currentUser?.email &&
                    userData["email"] != null &&
                    userData["uid"] != null)
                    .map<Widget>((userData) {
                  String avatarPath = _getUniqueAvatarPath(usedAvatars);
                  bool isSelected = _selectedUserIds.contains(userData["uid"]);
                  return FutureBuilder<String>(
                    future: _getLatestMessage(userData["uid"] ?? ''),
                    builder: (context, messageSnapshot) {
                      String subtitle = messageSnapshot.connectionState == ConnectionState.waiting
                          ? 'Loading latest message...'
                          : messageSnapshot.data ?? 'No messages available';

                      return GestureDetector(
                        onLongPress: _isSelecting
                            ? null
                            : () {
                          _onUserLongPress(userData["uid"] ?? '');
                        },
                        onTap: _isSelecting
                            ? () => _toggleUserSelection(userData["uid"])
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverEmail: userData["email"] ?? 'No email',
                                receiverId: userData["uid"] ?? '',
                              ),
                            ),
                          );
                        },
                        child: UserTitle2(
                          text: userData["email"] ?? 'No email',
                          avatar: avatarPath,
                          subtitle: subtitle,
                          onTap: () => _onUserTap(userData["uid"] ?? ''),
                          isSelected: isSelected,  // Add this line
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
