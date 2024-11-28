import 'package:flutter/material.dart';
import 'package:hey2/pages/about_page.dart';
import 'package:hey2/pages/group_home_page.dart';
import 'package:hey2/pages/profile_page.dart';
import 'package:hey2/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function(BuildContext) onLogout;

  const MyDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white.withOpacity(0.8), // Semi-transparent white background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Drawer Header with logo
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[500],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.message,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                // Profile ListTile
                ListTile(
                  leading: Icon(Icons.person, color: Theme.of(context).colorScheme.inversePrimary),
                  title: Text('Profile', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                ),
                // Group ListTile
                ListTile(
                  leading: Icon(Icons.group, color: Theme.of(context).colorScheme.inversePrimary),
                  title: Text('New Group', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupHomePage(),
                      ),
                    );
                  },
                ),
                // Settings ListTile
                ListTile(
                  leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.inversePrimary),
                  title: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                  },
                ),
                // About ListTile
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.inversePrimary),
                  title: Text('About', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            // Logout ListTile at the bottom
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary),
              title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              onTap: () => onLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
