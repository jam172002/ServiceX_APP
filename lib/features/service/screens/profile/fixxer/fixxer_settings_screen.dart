import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/profile/fixxer/fixxer_notifications_setting_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerSettingsScreen extends StatefulWidget {
  const FixxerSettingsScreen({super.key});

  @override
  State<FixxerSettingsScreen> createState() => _FixxerSettingsScreenState();
}

class _FixxerSettingsScreenState extends State<FixxerSettingsScreen> {
  String selectedLanguage = 'EN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),

          /// ===== SETTINGS =====
          _sectionTitle('Settings'),

          _settingsTile(
            icon: LucideIcons.globe,
            title: 'App Language',
            trailing: _languageToggle(),
          ),
          _divider(),

          _settingsTile(
            icon: LucideIcons.bell,
            title: 'Notification Preferences',
            onTap: () {
              Get.to(() => FixxerNotificationSettingScreen());
            },
          ),

          const SizedBox(height: 28),

          /// ===== HELP & SUPPORT =====
          _sectionTitle('Help & Support'),

          _settingsTile(
            icon: LucideIcons.hand_helping,
            title: 'Help Center for Professionals',
            onTap: () {},
          ),
          _divider(),

          _settingsTile(
            icon: LucideIcons.headphones,
            title: 'Contact Support',
            onTap: () {},
          ),
          _divider(),

          _settingsTile(
            icon: LucideIcons.shield_check,
            title: 'Policy Awareness',
            onTap: () {},
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Deactivate Account Tile
              InkWell(
                onTap: _showDeactivateDialog,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: const [
                      Icon(LucideIcons.pause, color: Colors.orange, size: 18),
                      SizedBox(width: 12),
                      Text(
                        'Deactivate Account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 20,
                width: 1,
                color: XColors.grey.withValues(alpha: 0.5),
              ),

              /// Delete Account Tile
              InkWell(
                onTap: _showDeleteAccountDialog,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: const [
                      Icon(
                        LucideIcons.trash_2,
                        color: Colors.redAccent,
                        size: 18,
                      ),
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
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// ===== LANGUAGE TOGGLE =====
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

  /// ===== LANGUAGE CONFIRMATION =====
  void _showLanguageConfirmationDialog() {
    final newLang = selectedLanguage == 'EN' ? 'FR' : 'EN';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Change language',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Switch app language to $newLang?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => selectedLanguage = newLang);
              Get.back();
            },
            child: Text('Confirm', style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );
  }

  /// ===== DEACTIVATE ACCOUNT =====
  void _showDeactivateDialog() {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Deactivate account'),
        content: const Text(
          'You can reactivate your account by logging in again.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== DELETE ACCOUNT =====
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        content: const Text(
          'This action is permanent and cannot be undone.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== SECTION TITLE =====
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// ===== SETTINGS TILE =====
  Widget _settingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = Colors.black54,
    Color titleColor = Colors.black87,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
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
