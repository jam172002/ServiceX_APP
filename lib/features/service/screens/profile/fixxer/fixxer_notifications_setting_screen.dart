import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerNotificationSettingScreen extends StatefulWidget {
  const FixxerNotificationSettingScreen({super.key});

  @override
  State<FixxerNotificationSettingScreen> createState() =>
      _FixxerNotificationSettingScreenState();
}

class _FixxerNotificationSettingScreenState
    extends State<FixxerNotificationSettingScreen> {
  // Section: Job Alerts
  bool pushJobAlerts = true;
  bool emailJobAlerts = false;

  // Section: Messages
  bool pushMessages = true;
  bool emailMessages = true;

  // Section: Reminders
  bool pushReminders = true;
  bool smsReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Notification Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          /// ================= Job Alerts =================
          const _SectionHeader(title: 'Job Alerts'),
          _notificationTile(
            icon: LucideIcons.bell_ring,
            title: 'Push Notifications',
            value: pushJobAlerts,
            onChanged: (v) => setState(() => pushJobAlerts = v),
          ),
          _divider(),
          _notificationTile(
            icon: LucideIcons.mails,
            title: 'Email Notifications',
            value: emailJobAlerts,
            onChanged: (v) => setState(() => emailJobAlerts = v),
          ),
          const SizedBox(height: 20),

          /// ================= Messages =================
          const _SectionHeader(title: 'Messages'),
          _notificationTile(
            icon: LucideIcons.bell_ring,
            title: 'Push Notifications',
            value: pushMessages,
            onChanged: (v) => setState(() => pushMessages = v),
          ),
          _divider(),
          _notificationTile(
            icon: LucideIcons.mails,
            title: 'Email Notifications',
            value: emailMessages,
            onChanged: (v) => setState(() => emailMessages = v),
          ),
          const SizedBox(height: 20),

          /// ================= Reminders =================
          const _SectionHeader(title: 'Reminders'),
          _notificationTile(
            icon: LucideIcons.bell_ring,
            title: 'Push Notifications',
            value: pushReminders,
            onChanged: (v) => setState(() => pushReminders = v),
          ),
          _divider(),
          _notificationTile(
            icon: LucideIcons.message_circle_more,
            title: 'SMS Notifications',
            value: smsReminders,
            onChanged: (v) => setState(() => smsReminders = v),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Notification tile widget
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

  // Divider
  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
}

// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
