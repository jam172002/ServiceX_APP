import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';

class FixxerNotificationsScreen extends StatefulWidget {
  const FixxerNotificationsScreen({super.key});

  @override
  State<FixxerNotificationsScreen> createState() =>
      _FixxerNotificationsScreenState();
}

class _FixxerNotificationsScreenState extends State<FixxerNotificationsScreen> {
  // Sample notifications for service providers
  List<Map<String, dynamic>> notifications = [
    {
      'type': 'job_request',
      'title': 'New Job Request',
      'subtitle': 'John requested a "Window Cleaning" service.',
      'time': '5m ago',
      'isRead': false,
    },
    {
      'type': 'booking_status',
      'title': 'Booking Confirmed',
      'subtitle': 'Your booking for "House Cleaning" is confirmed.',
      'time': '20m ago',
      'isRead': false,
    },
    {
      'type': 'reminder',
      'title': 'Upcoming Job',
      'subtitle': 'Reminder: Your "Plumbing" job starts in 1 hour.',
      'time': '1h ago',
      'isRead': true,
    },
    {
      'type': 'payment',
      'title': 'Payment Received',
      'subtitle': '\$75 has been added to your account.',
      'time': '3h ago',
      'isRead': true,
    },
    {
      'type': 'announcement',
      'title': 'Platform Update',
      'subtitle': 'New features are available for service providers.',
      'time': '1d ago',
      'isRead': true,
    },
  ];

  // Map notification type to icon
  IconData getIcon(String type) {
    switch (type) {
      case 'job_request':
        return Iconsax.clipboard_text; // new job
      case 'booking_status':
        return Iconsax.tick_circle; // confirmed
      case 'reminder':
        return Iconsax.clock; // reminder
      case 'payment':
        return LucideIcons.circle_dollar_sign; // payment
      case 'announcement':
        return Iconsax.notification; // update
      default:
        return Iconsax.notification;
    }
  }

  // Map notification type to color
  Color getIconColor(String type) {
    switch (type) {
      case 'job_request':
        return Colors.blue;
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
    // Sort unread notifications first
    notifications.sort((a, b) {
      if (a['isRead'] == b['isRead']) return 0;
      return !a['isRead'] ? -1 : 1;
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

// Reusable notification tile widget
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
              color: isRead ? Colors.grey.shade200 : iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isRead ? Colors.black87 : iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // Title + Subtitle
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
