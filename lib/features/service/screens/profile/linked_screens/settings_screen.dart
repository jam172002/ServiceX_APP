import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/profile/linked_screens/notifications_setting_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),

          /// Language
          _settingsTile(
            icon: LucideIcons.globe,
            title: 'Language',
            trailing: _languageToggle(),
          ),

          _divider(),

          /// Notifications (Navigate)
          _settingsTile(
            icon: LucideIcons.bell,
            title: 'Notifications',
            onTap: () {
              Get.to(() => NotificationsSettingScreen());
            },
          ),

          _divider(),

          /// Privacy Policy
          _settingsTile(
            icon: LucideIcons.cookie,
            title: 'Privacy Policy',
            onTap: () {},
          ),

          _divider(),

          /// Terms of Service
          _settingsTile(
            icon: LucideIcons.handshake,
            title: 'Terms of Service',
            onTap: () {},
          ),

          _divider(),

          /// Support
          _settingsTile(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          /// Delete Account
          _deleteAccountTile(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  //? Language Toggle (Primary Color Styled)

  Widget _languageToggle() {
    return GestureDetector(
      onTap: _showLanguageConfirmationDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: XColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: XColors.primary.withValues(alpha: 0.4)),
        ),
        child: Text(
          selectedLanguage,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: XColors.primary,
          ),
        ),
      ),
    );
  }

  //? Language Confirmation Dialog

  void _showLanguageConfirmationDialog() {
    final newLang = selectedLanguage == 'EN' ? 'FR' : 'EN';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Change language',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Switch app language to $newLang?',
          style: const TextStyle(fontSize: 13),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => selectedLanguage = newLang);
              Navigator.pop(context);
            },
            child: Text('Confirm', style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _deleteAccountTile() {
    return InkWell(
      onTap: _showDeleteAccountDialog,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: const [
            Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            SizedBox(width: 12),
            Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //? Delete Account Dialog

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete account',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        content: const Text(
          'This action is permanent and cannot be undone.',
          style: TextStyle(fontSize: 13),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //? Delete account logic
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Settings Tile
  Widget _settingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.black38,
                ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
}
