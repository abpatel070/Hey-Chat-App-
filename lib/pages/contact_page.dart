import 'package:flutter/material.dart';
import 'package:hey2/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendEmail(String message) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mr.abpatel070@gmail.com',
      query: Uri.encodeComponent('Subject=Contact Us&Body=$message'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text("Contact us",
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            )
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // More curved border
                ),
                hintText: 'Type your message here...',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'By clicking Send, you acknowledge that we may review diagnostic and performance information and the metadata associated with your account to try to troubleshoot and solve your reported issue. Learn more',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            Text(
              'For support with payments, go to Help in your payments home screen.',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            SizedBox(height: 10),
            Text(
              'We will respond to you in a Hey chat',
              style: TextStyle(fontSize: 12),
            ),
            Spacer(),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final message = _controller.text;
                  _sendEmail(message);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Send",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
