import 'package:flutter/material.dart';
import 'package:hey2/pages/contact_page.dart';
import 'profile_page.dart'; // Import the profile page

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _sendPushNotifications = false;
  bool _refreshAutomatically = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text("Settings",
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
      body: SingleChildScrollView( // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Settings',
              style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildListTile('Edit Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }),
            _buildListTile('Change Password', () {
              // Add navigation logic if needed
            }),
            _buildSwitchTile('Send Push Notifications', _sendPushNotifications, (value) {
              setState(() {
                _sendPushNotifications = value;
              });
            }),
            _buildSwitchTile('Changes Theme', _refreshAutomatically, (value) {
              setState(() {
                _refreshAutomatically = value;
              });
            }),

            _buildListTile('Help', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactPage ()),
              );
              // Add navigation logic if needed
            }),
            _buildListTile('FAQ', () {
              // Add navigation logic if needed
            }),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {  },
                child: const Text(
                  "Remove Changes",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.blue),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.blue),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveTrackColor: Colors.white,
    );
  }
}
