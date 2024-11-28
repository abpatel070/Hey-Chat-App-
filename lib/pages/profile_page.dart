import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  String _email = "";
  String _displayName = "User Name";
  String _selectedAvatar = 'default'; // Default avatar
  late Future<void> _loadProfileFuture;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _email = _user.email!;
    _nameController = TextEditingController();
    _aboutController = TextEditingController();
    _loadProfileFuture = _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    DocumentSnapshot<Map<String, dynamic>> userData =
    await _firestore.collection('users').doc(_user.uid).get();
    if (userData.exists) {
      setState(() {
        _nameController.text = userData.data()!['name'] ?? '';
        _aboutController.text = userData.data()!['about'] ?? '';
        _displayName = userData.data()!['name'] ?? 'User Name';
        _selectedAvatar = userData.data()!['avatar'] ?? 'default'; // Set default avatar if not present
      });
    }
  }

  Future<void> _saveProfileData() async {
    if (_nameController.text.isEmpty) {
      _showSnackbar("Please Enter Your Name");
    } else if (_aboutController.text.isEmpty) {
      _showSnackbar("Please Enter About You");
    } else {
      await _firestore.collection('users').doc(_user.uid).set({
        'name': _nameController.text,
        'about': _aboutController.text,
        'avatar': _selectedAvatar,
      });
      setState(() {
        _displayName = _nameController.text;
      });
      _showSnackbar("Profile Is Updated");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAvatarSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 13,
          itemBuilder: (context, index) {
            String avatarName = 'avatar${index + 1}';
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = avatarName;
                });
                Navigator.pop(context);
                _saveProfileData(); // Save selected avatar to database
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('android/assets/avatar/$avatarName.png'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.lightBlue[50],
          appBar: AppBar(
            title: const Text("Profile",
                style: TextStyle( color: Colors.blue)
            ),
            backgroundColor: Colors.lightBlue[50],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showAvatarSelectionSheet,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                      _selectedAvatar == 'default'
                          ? 'android/assets/default.png'
                          : 'android/assets/avatar/$_selectedAvatar.png',
                    ),
                    // child: _selectedAvatar == 'default'
                    //     ? const Icon(Icons.person, size: 60, color: Colors.white)
                    //     : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: "Your Name",
                  controller: _nameController,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildField(
                  label: "Add Bio",
                  controller: _aboutController,
                  icon: Icons.info,
                ),
                const SizedBox(height: 20),
                _buildNonEditableField(
                  label: _email,
                  icon: Icons.email,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _saveProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text("Save",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.blue[900]),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.blue[900]),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            minHeight: 0,
          ),
        ),
        style: TextStyle(color: Colors.blue[900]),
      ),
    );
  }

  Widget _buildNonEditableField({
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.blue[900]),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.blue[900]),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            minHeight: 0,
          ),
        ),
        style: TextStyle(color: Colors.blue[900]),
        readOnly: true,
      ),
    );
  }
}