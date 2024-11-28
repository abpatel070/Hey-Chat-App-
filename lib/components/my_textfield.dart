import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfield extends StatelessWidget {
  final Icon icon;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? postfixIcon;
  final List<TextInputFormatter>? inputFormatters; // Add this line
  final String? errorText; // Add this line for error handling

  const MyTextfield({
    Key? key,
    required this.icon,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.postfixIcon,
    this.inputFormatters, // Add this line
    this.errorText, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Apply inputFormatters
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon,
          suffixIcon: postfixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Capsule shape
            borderSide: BorderSide(color: Colors.black26), // Border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Capsule shape
            borderSide: BorderSide(color: Colors.black), // Border color when focused
          ),
          hintText: hintText,
          errorText: errorText, // Add this line
          hintStyle: TextStyle(
            color: Colors.black54,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Adjust padding for better appearance
        ),
      ),
    );
  }
}
