import 'package:flutter/material.dart';
import 'package:hey2/pages/home_page.dart';
import 'package:hey2/components/custom_toast.dart'; // Make sure to create the file for CustomToast

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _versionTapCount = 0;
  int _versionNumberTapCount = 0;

  void _showCustomToast(BuildContext context, String message, String imagePath) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: CustomToast(message: message, imagePath: imagePath),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          "About ",
          style: TextStyle(color: Colors.blue),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _versionTapCount++;
                  if (_versionTapCount >= 2) {
                    _showCustomToast(context, "Here's the logo!", 'android/assets/icon/toast_logo.png');
                    _versionTapCount = 0; // Reset count after showing toast
                  }
                });
              },
              child: const Text(
                'Version',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _versionNumberTapCount++;
                  if (_versionNumberTapCount >= 2) {
                    _showCustomToast(context, "7.11.4", 'android/assets/icon/toast_logo.png');
                    _versionNumberTapCount = 0; // Reset count after showing toast
                  }
                });
              },
              child: const Text(
                '7.11.4',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Debug log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Licenses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Terms & Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            const Text(
              'Copyright Signal Messenger Licensed under the GNU AGPLv3',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
