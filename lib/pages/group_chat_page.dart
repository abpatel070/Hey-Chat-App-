import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:hey2/services/chat/chat_service2.dart';
import 'package:hey2/pages/group_details_page.dart';


class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String senderName;

  GroupChatPage({required this.groupId, required this.groupName, required this.senderName, Key? key})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ChatService2 _chatService2 = ChatService2();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<String> _selectedMessageIds = {};
  bool _isInSelectionMode = false;

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      _isInSelectionMode = _selectedMessageIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelectedMessages() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Messages"),
          content: Text("Are you sure you want to delete the selected messages?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      for (String messageId in _selectedMessageIds) {
        await _chatService2.deleteGroupMessage(widget.groupId, messageId);
      }
      setState(() {
        _selectedMessageIds.clear();
        _isInSelectionMode = false;
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService2.sendGroupMessage(
        groupId: widget.groupId,
        message: _messageController.text,
        senderName: widget.senderName,
      );
      _messageController.clear();
    }
  }

  Future<User?> _getCurrentUser() async {
    return _auth.currentUser;
  }

  Widget _buildMessageList() {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text("User not logged in"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _chatService2.getGroupMessagesStream(widget.groupId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No messages yet"));
            }

            List<DocumentSnapshot> messages = snapshot.data!.docs;
            messages.sort((a, b) => (b.data() as Map<String, dynamic>)['timestamp']
                .compareTo((a.data() as Map<String, dynamic>)['timestamp']));

            return ListView(
              reverse: true,
              children: messages.map<Widget>((doc) => _buildMessageItem(doc)).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderName'] == widget.senderName;
    bool isSelected = _selectedMessageIds.contains(doc.id);

    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    var containerColor = isSelected
        ? Colors.blue[200]
        : (isCurrentUser ? Colors.blue[100] : Colors.grey[200]);
    var textColor = Colors.black;

    var timestamp = data['timestamp'] != null
        ? DateFormat('h:mm a').format((data['timestamp'] as Timestamp).toDate())
        : '';

    return GestureDetector(
      onLongPress: () => _toggleMessageSelection(doc.id),
      onTap: _isInSelectionMode ? () => _toggleMessageSelection(doc.id) : null,
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                data['senderName'] ?? 'Unknown User',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                data['message'] ?? '',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timestamp,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.done_all,
                        color: Colors.blue,
                        size: 16.0,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGroupDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(groupId: widget.groupId, groupName: widget.groupName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: ClipPath(
          clipper: CustomShapeClipper(),
          child: AppBar(
            backgroundColor: Colors.blue,
            title: _isInSelectionMode
                ? Text("${_selectedMessageIds.length} selected")
                : GestureDetector(
              onTap: _navigateToGroupDetails,
              child: Text(widget.groupName),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actions: _isInSelectionMode
                ? [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: _deleteSelectedMessages,
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedMessageIds.clear();
                    _isInSelectionMode = false;
                  });
                },
              ),
            ]
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Define CustomShapeClipper here
class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
