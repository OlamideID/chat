import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.text,
    this.onTap,
    this.delete,
    this.block,
    this.lastMessage = '',
    this.initial,
    this.count = 0,
  });

  final String text;
  final String? initial;
  final Function()? onTap;
  final Function()? delete;
  final Function()? block;
  final String lastMessage;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: GestureDetector(
        onLongPress: delete,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                // Avatar with initial
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(text), // Generate color from name
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial?.toString().toUpperCase() ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // User Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Unread Count Badge
                if (count != null && count! > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          Colors.green, // WhatsApp green for the unread count
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      count.toString(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to generate a background color for the avatar based on the user's name
  Color _getAvatarColor(String name) {
    // Use a simple hash function to generate a color from the user's name
    int hash = name.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.7);
  }
}
