import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/components/my_textfield.dart';
import 'package:hey2/pages/home_page.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void login(BuildContext context) async {
    final authService = AuthService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Authenticate user
      User? user = await authService.signInWithEmailPassword(
        _emailOrUsernameController.text.trim(),
        _pwController.text.trim(),
      );

      Navigator.pop(context); // Close the loading dialog

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(), // Navigate to home page
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email/username or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.message,
                size: 60,
                color: Colors.blue,
              ),
              const SizedBox(height: 50),
              const Text(
                "Welcome Back, You've been missed!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            // Handle forgot password tap
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.blue,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: MyTextfield(
                        icon: const Icon(Icons.email),
                        hintText: "Email or Username",
                        obscureText: false,
                        controller: _emailOrUsernameController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: MyTextfield(
                        icon: const Icon(Icons.lock),
                        hintText: "Password",
                        obscureText: !_isPasswordVisible,
                        controller: _pwController,
                        keyboardType: TextInputType.visiblePassword,
                        postfixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            // Handle forgot password tap
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SwipeButton.expand(
                  thumb: const Icon(
                    Icons.double_arrow_rounded,
                    color: Colors.white,
                  ),
                  child: const Text(
                    "Swipe to Sign In",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  activeThumbColor: Colors.blue,
                  activeTrackColor: Colors.white,
                  onSwipe: () {
                    login(context);
                  },
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Not a Member?",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Register now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
}
