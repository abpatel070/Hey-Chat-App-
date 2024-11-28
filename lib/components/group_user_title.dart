import 'package:flutter/material.dart';

class GroupUserTitle extends StatelessWidget {
  final String groupName;
  final String avatar;
  final int memberCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const GroupUserTitle({
    Key? key,
    required this.groupName,
    required this.avatar,
    required this.memberCount,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            padding: const EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundImage: avatar.isNotEmpty
                          ? AssetImage(avatar)
                          : AssetImage('android/assets/avatar/avatar2.png'),
                    ),
                    if (isSelected)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    memberCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider to add the thin black underline between containers
          const Divider(
            color: Colors.black45,
            thickness: 0.5,
            indent: 75,  // Optional: Adjusts the start position of the line
            endIndent: 1,  // Optional: Adjusts the end position of the line
          ),
        ],
      ),
    );
  }
}
