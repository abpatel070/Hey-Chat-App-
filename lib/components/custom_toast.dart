import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final String imagePath;

  const CustomToast({Key? key, required this.message, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black.withOpacity(0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 20.0,
            height: 20.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
