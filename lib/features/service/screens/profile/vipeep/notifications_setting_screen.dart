import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class NotificationsSettingScreen extends StatefulWidget {
  const NotificationsSettingScreen({super.key});

  @override
  State<NotificationsSettingScreen> createState() =>
      _NotificationsSettingScreenState();
}

class _NotificationsSettingScreenState
    extends State<NotificationsSettingScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool smsEnabled = false;
  bool reminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Notification Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),

          _notificationTile(
            icon: LucideIcons.bell_ring,
            title: 'Push Notifications',
            value: pushEnabled,
            onChanged: (v) => setState(() => pushEnabled = v),
          ),

          _divider(),

          _notificationTile(
            icon: LucideIcons.mails,
            title: 'Email Notifications',
            value: emailEnabled,
            onChanged: (v) => setState(() => emailEnabled = v),
          ),

          _divider(),

          _notificationTile(
            icon: LucideIcons.message_circle_more,
            title: 'SMS Notifications',
            value: smsEnabled,
            onChanged: (v) => setState(() => smsEnabled = v),
          ),

          _divider(),

          _notificationTile(
            icon: LucideIcons.siren,
            title: 'Reminder Notifications',
            value: reminderEnabled,
            onChanged: (v) => setState(() => reminderEnabled = v),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  //? Notification Tile

  Widget _notificationTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: XColors.primary,
              activeTrackColor: XColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
}
