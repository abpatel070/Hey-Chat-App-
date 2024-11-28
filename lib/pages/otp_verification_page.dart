import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey2/services/auth/auth_service.dart';
import 'package:hey2/pages/home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final bool isRegistration;

  const OtpVerificationPage({
    Key? key,
    required this.email,
    required this.password,
    required this.username,
    required this.isRegistration,
  }) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final AuthService _authService = AuthService();
  // Increased the controllers and focus nodes count to 6
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {  // Updated OTP length to 6
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
      return;
    }

    try {
      if (widget.isRegistration) {
        await _authService.verifyEmailOTP(widget.email, otp);
        await _authService.signUpWithEmailPassword(
          widget.email,
          widget.password,
          widget.username,
        );
      } else {
        await _authService.signInWithEmailPassword(
          widget.email,
          widget.password,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Image.asset(
                    'android/assets/otpimage.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Enter Verification code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'We are automatically detecting a SMS\nsend to your E-mail Address',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6, // Changed the number of text boxes to 6
                        (index) => SizedBox(
                      width: 50, // Adjusted the width to fit 6 boxes
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {  // Updated the focus logic to 6 boxes
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implement resend OTP functionality
                    },
                    child: Text(
                      "Don't receive the OTP? RESEND OTP",
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Text(
                      'Verify',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[500],
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
