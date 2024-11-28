  import 'package:flutter/material.dart';

  class UserTitle2 extends StatelessWidget {
    final String text;
    final String avatar;
    final String subtitle;
    final void Function()? onTap;
    final bool isSelected;

    const UserTitle2({
      super.key,
      required this.text,
      required this.avatar,
      required this.subtitle,
      required this.onTap,
      required this.isSelected, // Add this parameter
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.lightBlueAccent.withOpacity(0.3) // Highlight selected users
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
          padding: EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
