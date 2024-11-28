import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hey2/components/user_title.dart';
import 'package:hey2/pages/chat_page.dart';
import 'package:hey2/pages/group_home_page.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/components/my_drawer.dart';
import 'package:hey2/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey2/pages/user_list.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  bool _isSearching = false;
  bool _isSelectionMode = false;
  TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final Random _random = Random();
  Set<String> _selectedUsers = {};

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

  void logout(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      await _authService.signOut();
      Navigator.of(context).pop();
    }
  }

  Future<String> _getLatestMessage(String userId) async {
    return await _chatService.getLatestMessage(userId, FirebaseAuth.instance.currentUser!.uid);
  }

  Future<int> _getUnreadMessageCount(String userId) async {
    return await _chatService.getUnreadMessageCount(userId);
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
      _isSelectionMode = _selectedUsers.isNotEmpty;
    });
  }



  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedUsers.clear();
    });
  }

  void _deleteSelectedUsers() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete all messages with the selected users?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      for (String userId in _selectedUsers) {
        await _chatService.deleteUserAndChats(userId);
      }
      _cancelSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Messages deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(
        onLogout: (context) => logout(context),
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[500],
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 80,
        title: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedUsers.isNotEmpty ? '${_selectedUsers.length} selected' : 'Hey',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_selectedUsers.isEmpty)
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                if (_selectedUsers.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteSelectedUsers();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
            if (_isSearching && _selectedUsers.isEmpty)
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
          print("Current user: ${currentUser?.email}");

          return StreamBuilder(
            stream: _chatService.getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'android/assets/backgroundhome.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    const Text(
                      "No Chats, Yet! ",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                );
              }

              List<Map<String, dynamic>> users = (snapshot.data as List)
                  .where((element) => element != null)
                  .map((element) => element as Map<String, dynamic>)
                  .toList();

              Set<String> usedAvatars = {};

              return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  thickness: 1.0,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var userData = users[index];
                  String avatarPath = _getUniqueAvatarPath(usedAvatars);
                  return FutureBuilder<String>(
                    future: _getLatestMessage(userData["uid"]),
                    builder: (context, messageSnapshot) {
                      String subtitle = messageSnapshot.connectionState == ConnectionState.waiting
                          ? 'Loading latest message...'
                          : messageSnapshot.data ?? 'No messages available';

                      return FutureBuilder<int>(
                        future: _getUnreadMessageCount(userData["uid"]),
                        builder: (context, unreadCountSnapshot) {
                          int unreadCount = unreadCountSnapshot.data ?? 0;
                          print("Unread count for ${userData["email"]}: $unreadCount"); // Debug print
                          return UserTitle(
                            text: userData["email"] ?? 'No email',
                            avatar: avatarPath,
                            subtitle: subtitle,
                            unreadCount: unreadCount,
                            onTap: () async {
                              if (_selectedUsers.isNotEmpty) {
                                _toggleUserSelection(userData["uid"]);
                              } else {
                                await _chatService.markMessagesAsRead(userData["uid"]);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      receiverEmail: userData["email"] ?? 'No email',
                                      receiverId: userData["uid"] ?? '',
                                    ),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              _toggleUserSelection(userData["uid"]);
                            },
                            isSelected: _selectedUsers.contains(userData["uid"]),
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
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          height: 80,
          color: Colors.grey,
          child: BottomNavigationBar(
            backgroundColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                // Handle chats
                _pageController.jumpToPage(index);
              } else if (index == 1 || index == 3) {
                // Show Lottie animation for Updates and Calls
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: Lottie.asset('android/assets/animation/soon.json'), // Path to soon.json
                  ),
                );
              } else if (index == 2) {
                // Navigate to group_home_page.dart for Communities
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupHomePage()),
                );
              }
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.update),
                label: 'Updates',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Communities',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_call),
                label: 'Calls',
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserListPage()),
            );
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}