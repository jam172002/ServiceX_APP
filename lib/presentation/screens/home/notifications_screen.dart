import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications
  List<Map<String, dynamic>> notifications = [
    {
      'type': 'message',
      'title': 'New Message from John',
      'subtitle': 'Hey! Can you start the cleaning job tomorrow?',
      'time': '10m ago',
      'isRead': false,
    },
    {
      'type': 'offer',
      'title': 'New Job Offer',
      'subtitle': 'You received an offer on "Window Cleaning Request".',
      'time': '30m ago',
      'isRead': false,
    },
    {
      'type': 'booking_status',
      'title': 'Booking Confirmed',
      'subtitle': 'Your booking for "House Cleaning" is confirmed.',
      'time': '1h ago',
      'isRead': true,
    },
    {
      'type': 'reminder',
      'title': 'Upcoming Booking',
      'subtitle': 'Reminder: Your "Plumbing" job starts in 2 hours.',
      'time': '2h ago',
      'isRead': false,
    },
    {
      'type': 'payment',
      'title': 'Payment Received',
      'subtitle': '\$50 has been added to your account.',
      'time': '5h ago',
      'isRead': true,
    },
    {
      'type': 'announcement',
      'title': 'Service Update',
      'subtitle': 'New services available in your area.',
      'time': '1d ago',
      'isRead': true,
    },
  ];

  // Map notification type to icon and color
  IconData getIcon(String type) {
    switch (type) {
      case 'message':
        return Iconsax.message_text;
      case 'offer':
        return Iconsax.gift;
      case 'booking_status':
        return Iconsax.tick_circle;
      case 'reminder':
        return Iconsax.clock;
      case 'payment':
        return LucideIcons.circle_dollar_sign;
      case 'announcement':
        return Iconsax.notification;
      default:
        return Iconsax.notification;
    }
  }

  Color getIconColor(String type) {
    switch (type) {
      case 'message':
        return Colors.blue;
      case 'offer':
        return Colors.orange;
      case 'booking_status':
        return Colors.green;
      case 'reminder':
        return Colors.purple;
      case 'payment':
        return Colors.teal;
      case 'announcement':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort unread notifications on top
    notifications.sort((a, b) {
      if (a['isRead'] == b['isRead']) return 0;
      if (!a['isRead']) return -1;
      return 1;
    });

    return Scaffold(
      appBar: XAppBar(title: 'Notifications'),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final item = notifications[index];
          return GestureDetector(
            onTap: () {
              if (!item['isRead']) {
                setState(() {
                  notifications[index]['isRead'] = true;
                });
              }
            },
            child: _NotificationTile(
              icon: getIcon(item['type']),
              iconColor: getIconColor(item['type']),
              title: item['title'],
              subtitle: item['subtitle'],
              time: item['time'],
              isRead: item['isRead'],
            ),
          );
        },
      ),
    );
  }
}

// Reusable notification tile
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.grey.shade200
                  : iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isRead ? Colors.black87 : iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Time
          Text(time, style: TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }
}
