import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/components/my_textfield.dart';
import 'package:hey2/pages/otp_verification_page.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Add this flag for loading state
  String? _usernameError;
  String? _passwordError;

  Future<bool> isUsernameUnique(String username) async {
    final auth = AuthService();
    return await auth.isUsernameAvailable(username);
  }

  void register(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start showing the loading indicator
    });

    final auth = AuthService();

    if (_usernameController.text.length > 6) {
      setState(() {
        _usernameError = 'Username cannot exceed 6 characters';
        _isLoading = false; // Stop loading indicator on error
      });
      return;
    } else {
      setState(() {
        _usernameError = null;
      });
    }

    if (_pwController.text.length != 6) {
      setState(() {
        _passwordError = 'Password must be exactly 6 characters long';
        _isLoading = false; // Stop loading indicator on error
      });
      return;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    if (_pwController.text == _confirmpwController.text) {
      bool isUnique = await isUsernameUnique(_usernameController.text.trim());
      if (!isUnique) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Error'),
            content: const Text('Username is already taken.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading on error
        });
        return;
      }

      try {
        await auth.sendEmailOTP(_emailController.text.trim());

        // Navigate to OTP verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: _emailController.text.trim(),
              password: _pwController.text.trim(),
              username: _usernameController.text.trim(),
              isRegistration: true,
            ),
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading after navigation
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false; // Stop loading on error
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Passwords Don't Match!"),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      setState(() {
        _isLoading = false; // Stop loading on error
      });
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
              const SizedBox(height: 30),
              const Text(
                "Let's Create An Account!",
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
                            // Handle registration tap
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'garamond',
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
                        hintText: "Email",
                        obscureText: false,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6), // Restrict to 6 characters
                        ],
                        errorText: _passwordError,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: MyTextfield(
                        icon: const Icon(Icons.lock),
                        hintText: "Confirm Password",
                        obscureText: !_isPasswordVisible,
                        controller: _confirmpwController,
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6), // Restrict to 6 characters
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: MyTextfield(
                        icon: const Icon(Icons.person),
                        hintText: "Username",
                        obscureText: false,
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        errorText: _usernameError,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15), // Restrict to 6 characters
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator() // Show loading indicator when _isLoading is true
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SwipeButton.expand(
                    thumb: const Icon(
                      Icons.double_arrow_rounded,
                      color: Colors.white,
                    ),
                    child: const Text(
                      "Swipe to Register",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                    activeThumbColor: Colors.blue,
                    activeTrackColor: Colors.white,
                    onSwipe: () {
                      register(context); // Register and show loading
                    },
                  ),
                ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                //
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  "Already have an account? Login now",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
