import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hey2/services/chat/chat_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

extension SetExtension<E> on Set<E> {
  void toggle(E element) {
    if (contains(element)) {
      remove(element);
    } else {
      add(element);
    }
  }
}

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLottieVisible = false;

  bool _isEmojiVisible = false;  // Track emoji visibility
  FocusNode _focusNode = FocusNode();  // Handle keyboard focus


  // Use ValueNotifier to track selected messages
  final ValueNotifier<Set<String>> _selectedMessageIds = ValueNotifier<Set<String>>({});


  Future<User?> _getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isEmojiVisible = false;  // Hide emoji picker when the text field is focused
        });
      }
    });
  }

  // // Add a function to show Lottie animation
  // void _showLottieAnimation() {
  //   setState(() {
  //     _isLottieVisible = true;
  //   });
  //
  //   // Hide the Lottie animation after a delay (optional)
  //   Future.delayed(Duration(seconds: 3), () {
  //     setState(() {
  //       _isLottieVisible = false;
  //     });
  //   });
  // }

  void _showLottieOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'android/assets/animation/soon.json',
            width: 200,
            height: 200,
            repeat: false,
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();  // Close the overlay after the animation finishes
    });
  }



  void _markMessagesAsRead() async {
    await _chatService.markMessagesAsRead(widget.receiverId);
  }

  void sendMessage({String? imageUrl}) async {
    if (_messageController.text.isNotEmpty || imageUrl != null) {
      User? currentUser = await _getCurrentUser();
      if (currentUser != null) {
        await _chatService.sendMessage(
          widget.receiverId,
          _messageController.text,
          currentUser.uid,
          imageUrl: imageUrl,
        );
        _messageController.clear();
        // Mark messages as read after sending a new message
        _markMessagesAsRead();
      }
    }
  }
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? imageUrl = await _chatService.uploadImage(imageFile);
      sendMessage(imageUrl: imageUrl);
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _messageController.text = _messageController.text + emoji.emoji;
  }

  void _toggleEmojiPicker() {
    if (_isEmojiVisible) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
  }

  void _onMessageLongPress(String messageId) {
    _selectedMessageIds.value = {..._selectedMessageIds.value}..toggle(messageId);
  }

  void _deleteSelectedMessages() async {
    User? currentUser = await _getCurrentUser();
    if (currentUser == null) return;

    String senderId = currentUser.uid;

    await _chatService.deleteMessages(senderId, widget.receiverId, _selectedMessageIds.value);

    _selectedMessageIds.value = {};
  }



  Widget customToast(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.green),
          SizedBox(width: 12.0),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }



  void _copySelectedMessages() async {
    if (_selectedMessageIds.value.isEmpty) return;

    User? currentUser = await _getCurrentUser();
    if (currentUser == null) return;

    String senderId = currentUser.uid;
    List<String> selectedMessages = [];

    for (var messageId in _selectedMessageIds.value) {
      var doc = await _chatService.getMessage(widget.receiverId, senderId, messageId);
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        selectedMessages.add(data["message"]);
      }
    }

    String concatenatedMessages = selectedMessages.join('\n');
    Clipboard.setData(ClipboardData(text: concatenatedMessages));

    _selectedMessageIds.value = {};

    FToast fToast = FToast();
    fToast.init(context);
    fToast.showToast(
      child: customToast("Message Copied"),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverEmail,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'last seen Jul 05 at 8:16 PM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              ValueListenableBuilder<Set<String>>(
                valueListenable: _selectedMessageIds,
                builder: (context, selectedMessageIds, child) {
                  if (selectedMessageIds.isNotEmpty) {
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: _deleteSelectedMessages,
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (item) {
                            if (item == 0) {
                              _copySelectedMessages();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text('Copy'),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.call, color: Colors.white),
                          onPressed: _showLottieOverlay,  // Show overlay animation
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (item) {
                            if (item == 0) {
                              _deleteSelectedMessages();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text('Delete Selected Messages'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildUserInput(),
              if (_isEmojiVisible) _buildEmojiPicker(),
            ],
          ),
          if (_isLottieVisible)
            Center(
              child: Lottie.asset(
                'android/assets/animation/soon.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
            ),
        ],
      ),
    );
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

        User currentUser = userSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: _chatService.getMessages(widget.receiverId, currentUser.uid),
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
            messages.sort((a, b) => (b.data() as Map<String, dynamic>)['timestamp'].compareTo((a.data() as Map<String, dynamic>)['timestamp']));

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
    bool isCurrentUser = data['senderId'] == _auth.currentUser?.uid;

    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Modify the container color for the left-side message (non-current user)
    var containerColor = isCurrentUser ? Colors.blue[100] : Colors.grey[300]; // Left-side messages will be grey
    var textColor = isCurrentUser ? Colors.black : Colors.black;

    var timestamp = data['timestamp'] != null
        ? DateFormat('h:mm a').format((data['timestamp'] as Timestamp).toDate())
        : '';

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _selectedMessageIds,
      builder: (context, selectedMessageIds, child) {
        bool isSelected = selectedMessageIds.contains(doc.id);
        return GestureDetector(
          onLongPress: () => _onMessageLongPress(doc.id),
          onTap: () {
            if (selectedMessageIds.isNotEmpty) {
              _onMessageLongPress(doc.id);
            }
          },
          child: Align(
            alignment: alignment,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[200] : containerColor,
                    borderRadius: BorderRadius.circular(20.0),
                    border: isSelected
                        ? Border.all(color: Colors.green, width: 2.0)
                        : null,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null)
                        Image.network(
                          data['imageUrl'],
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      if (data["message"] != null)
                        Text(
                          data["message"],
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timestamp,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                if (isSelected)
                  Positioned(
                    top: 0,
                    left: isCurrentUser ? null : 0,
                    right: isCurrentUser ? 0 : null,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildUserInput() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.black),
            onPressed: _toggleEmojiPicker,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.black),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _onEmojiSelected(emoji);
      },

    );
  }

}


class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }

}
