import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class AllChatScreenCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String date;
  final String time;
  final int unreadCount;
  final String avatar;
  final VoidCallback onTap;

  const AllChatScreenCard({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.date,
    required this.time,
    required this.unreadCount,
    this.avatar = XImages.serviceProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(backgroundImage: AssetImage(avatar), radius: 35),
            const SizedBox(width: 10),

            // Name + Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Name
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// Last Message
                  Text(
                    lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: XColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Time + Date + Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Unread Messages Badge (only visible if > 0)
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: XColors.success,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: XColors.secondaryBG,
                        ),
                      ),
                    ),
                  ),

                // Date
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: XColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Time
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 8,
                    color: XColors.grey,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
