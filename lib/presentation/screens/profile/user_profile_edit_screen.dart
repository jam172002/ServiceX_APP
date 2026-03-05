import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/presentation/controllers/auth_controller.dart';
import 'package:servicex_client_app/presentation/screens/profile/controller/user_profile_controller.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  late UserProfileController _c;

  // Local editable state — seeded from AuthController.currentUser on init
  late String _name;
  late String _email;
  late String _phone;
  late Gender _gender;

  // Validation errors
  String? _nameError;
  String? _phoneError;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _c = Get.find<UserProfileController>();

    final user = Get.find<AuthController>().currentUser.value;
    _name = user?.name ?? '';
    _email = user?.email ?? '';
    _phone = user?.phone ?? '';
    _gender = user?.gender ?? Gender.other;
  }

  // ── IMAGE PICKER ──────────────────────────────────────────────────────────
  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetTile('Camera', LucideIcons.camera,
                    () => _c.pickImage(ImageSource.camera)),
            _sheetTile('Gallery', LucideIcons.image,
                    () => _c.pickImage(ImageSource.gallery)),
          ],
        ),
      ),
    );
  }

  // ── EDIT FIELD DIALOG ─────────────────────────────────────────────────────
  void _editField(
      String title,
      String currentValue,
      Function(String) onSave, {
        String? type,
      }) {
    final ctrl = TextEditingController(text: currentValue);
    String? error;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: XColors.secondaryBG,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              keyboardType: type == 'phone'
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                errorText: error,
                errorStyle: const TextStyle(fontSize: 10),
              ),
            ),
            actionsPadding:
            const EdgeInsets.symmetric(horizontal: 8),
            actions: [
              TextButton(
                  onPressed: Get.back,
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final value = ctrl.text.trim();
                  String? validation;
                  if (value.isEmpty) validation = 'Required';
                  if (type == 'name' && value.length > 50) {
                    validation = 'Max 50 characters';
                  }
                  if (validation != null) {
                    setDialogState(() => error = validation);
                    return;
                  }
                  onSave(value);
                  Get.back();
                },
                child: Text('Save',
                    style: TextStyle(color: XColors.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── VALIDATE & SAVE ───────────────────────────────────────────────────────
  Future<void> _saveChanges() async {
    bool valid = true;
    setState(() {
      _nameError = null;
      _phoneError = null;

      if (_name.isEmpty || _name.length > 50) {
        _nameError = 'Required, max 50 characters';
        valid = false;
      }
      if (_phone.isEmpty) {
        _phoneError = 'Required';
        valid = false;
      }
    });

    if (!valid) return;

    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Save',
            style:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        content: const Text(
          'Are you sure you want to save all changes?',
          style: TextStyle(fontSize: 12),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Confirm',
                style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _c.saveProfile(
      name: _name,
      phone: _phone,
      gender: _gender,
    );

    if (success) {
      // Show snackbar BEFORE closing the screen — avoids "No Overlay" crash
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully.'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Get.back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save changes. Please try again.'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XColors.primaryBG,
      appBar: XAppBar(title: 'Edit Profile'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── AVATAR ───────────────────────────────────────────
                  Obx(() {
                    final picked = _c.pickedImage.value;
                    final networkUrl = Get.find<AuthController>()
                        .currentUser
                        .value
                        ?.photoUrl ??
                        '';

                    return GestureDetector(
                      onTap: _showImagePicker,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: XColors.secondaryBG,
                            backgroundImage: picked != null
                                ? FileImage(picked) as ImageProvider
                                : networkUrl.isNotEmpty
                                ? NetworkImage(networkUrl)
                                : null,
                            child: (picked == null && networkUrl.isEmpty)
                                ? Icon(
                              Iconsax.user,
                              size: 36,
                              color: XColors.primary
                                  .withValues(alpha: 0.7),
                            )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: XColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.camera,
                                size: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ── NAME ─────────────────────────────────────────────
                  _editCard(
                    icon: LucideIcons.user,
                    title: _name.isEmpty ? 'Tap to add name' : _name,
                    errorText: _nameError,
                    onTap: () => _editField(
                      'Name',
                      _name,
                          (v) => setState(() => _name = v),
                      type: 'name',
                    ),
                  ),

                  // ── EMAIL (read-only) ─────────────────────────────────
                  _editCard(
                    icon: Iconsax.message,
                    title: _email,
                    isReadOnly: true,
                    subtitle: 'Email cannot be changed',
                  ),

                  // ── PHONE ─────────────────────────────────────────────
                  _editCard(
                    icon: LucideIcons.phone,
                    title: _phone.isEmpty ? 'Tap to add phone' : _phone,
                    errorText: _phoneError,
                    onTap: () => _editField(
                      'Phone Number',
                      _phone,
                          (v) => setState(() => _phone = v),
                      type: 'phone',
                    ),
                  ),

                  // ── GENDER ────────────────────────────────────────────
                  _editCard(
                    icon: LucideIcons.users,
                    title: 'Gender',
                    custom: Wrap(
                      spacing: 8,
                      children: Gender.values.map((g) {
                        final isActive = g == _gender;
                        final label = g.name[0].toUpperCase() +
                            g.name.substring(1);
                        return GestureDetector(
                          onTap: () => setState(() => _gender = g),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? XColors.primary
                                  : XColors.secondaryBG,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? XColors.primary
                                    : XColors.primary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── SAVE BUTTON ───────────────────────────────────────────────
          Obx(() {
            final saving = _c.isSaving.value;
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: saving ? null : _saveChanges,
                  child: saving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Widget _editCard({
    required IconData icon,
    required String title,
    Widget? custom,
    VoidCallback? onTap,
    String? errorText,
    String? subtitle,
    bool isReadOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: XColors.secondaryBG,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: isReadOnly
                      ? XColors.grey
                      : XColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: custom ??
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: isReadOnly
                            ? XColors.grey
                            : Colors.black87,
                      ),
                    ),
              ),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(LucideIcons.pencil,
                      size: 16, color: XColors.primary),
                ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 24),
              child: Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 10, color: XColors.grey),
              ),
            ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                errorText,
                style: const TextStyle(
                    color: Colors.redAccent, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetTile(
      String title, IconData icon, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: XColors.primary),
        title: Text(title,
            style: const TextStyle(color: Colors.black87)),
        onTap: () {
          Get.back();
          onTap();
        },
      );
}