import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  File? profileImage;

  String name = "Ali Haider";
  String email = "ali@example.com";
  String phone = "+1 123-456-7890";
  String gender = "Male";

  final picker = ImagePicker();

  // Regex patterns
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final phoneRegexUSA = RegExp(r'^\+1\s?\(?\d{3}\)?[-\s]?\d{3}[-\s]?\d{4}$');
  final phoneRegexFR = RegExp(
    r'^\+33\s?\d{1}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}[\s.-]?\d{2}$',
  );

  String? nameError;
  String? emailError;
  String? phoneError;

  Future<void> _pickImage(ImageSource source) async {
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => profileImage = File(image.path));
      Get.back();
    }
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetTile(
              "Camera",
              LucideIcons.camera,
              () => _pickImage(ImageSource.camera),
            ),
            _sheetTile(
              "Gallery",
              LucideIcons.image,
              () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _editField(
    String title,
    String currentValue,
    Function(String) onSave, {
    String? type,
  }) {
    final controller = TextEditingController(text: currentValue);
    String? error;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: XColors.secondaryBG,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  keyboardType: type == 'email'
                      ? TextInputType.emailAddress
                      : type == 'phone'
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    errorText: error,
                    errorStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
            actions: [
              TextButton(onPressed: Get.back, child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  final value = controller.text.trim();
                  String? validation;

                  if (value.isEmpty) validation = "Required";
                  if (type == 'email' && !emailRegex.hasMatch(value)) {
                    validation = "Invalid email";
                  }
                  if (type == 'phone' &&
                      !(phoneRegexUSA.hasMatch(value) ||
                          phoneRegexFR.hasMatch(value))) {
                    validation = "Invalid USA/FR phone";
                  }
                  if (type == 'name' && value.length > 50) {
                    validation = "Max 50 chars";
                  }

                  if (validation != null) {
                    setDialogState(() => error = validation);
                    return;
                  }

                  onSave(value);
                  Get.back();
                },
                child: Text("Save", style: TextStyle(color: XColors.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveAllChanges() {
    bool valid = true;
    setState(() {
      nameError = null;
      emailError = null;
      phoneError = null;

      if (name.isEmpty || name.length > 50) {
        nameError = "Required, max 50 chars";
        valid = false;
      }
      if (!emailRegex.hasMatch(email)) {
        emailError = "Invalid email";
        valid = false;
      }
      if (!(phoneRegexUSA.hasMatch(phone) || phoneRegexFR.hasMatch(phone))) {
        phoneError = "Invalid USA or FR phone";
        valid = false;
      }
      if (gender.isEmpty) valid = false;
    });

    if (!valid) return;

    // Confirmation dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Confirm Save",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        content: const Text(
          "Are you sure you want to save all changes?",
          style: TextStyle(fontSize: 12),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Get.back();
              //? Save changes API
            },
            child: Text("Confirm", style: TextStyle(color: XColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XColors.primaryBG,
      appBar: XAppBar(title: 'Edit Profile'),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: profileImage == null
                            ? XColors.secondaryBG
                            : null,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : null,
                        child: profileImage == null
                            ? Icon(
                                Iconsax.user,
                                size: 36,
                                color: XColors.primary.withValues(alpha: 0.7),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _editCard(
                      icon: LucideIcons.user,
                      title: "Name",
                      value: name,
                      errorText: nameError,
                      onTap: () => _editField(
                        "Name",
                        name,
                        (v) => setState(() => name = v),
                        type: 'name',
                      ),
                    ),
                    _editCard(
                      icon: Iconsax.message,
                      title: "Email",
                      value: email,
                      errorText: emailError,
                      onTap: () => _editField(
                        "Email",
                        email,
                        (v) => setState(() => email = v),
                        type: 'email',
                      ),
                    ),
                    _editCard(
                      icon: LucideIcons.phone,
                      title: "Phone",
                      value: phone,
                      errorText: phoneError,
                      onTap: () => _editField(
                        "Phone Number",
                        phone,
                        (v) => setState(() => phone = v),
                        type: 'phone',
                      ),
                    ),
                    _editCard(
                      icon: LucideIcons.users,
                      title: "Gender",
                      custom: Row(
                        children: ["Male", "Female", "Other"].map((g) {
                          final isActive = g == gender;
                          return GestureDetector(
                            onTap: () => setState(() => gender = g),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? XColors.primary
                                    : XColors.secondaryBG,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isActive
                                      ? XColors.primary
                                      : XColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                g,
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
                      onTap: null,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Full-width bottom button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveAllChanges,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editCard({
    required IconData icon,
    required String title,
    String? value,
    Widget? custom,
    VoidCallback? onTap,
    String? errorText,
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
              Icon(icon, size: 16, color: XColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child:
                    custom ??
                    Text(
                      value ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
              ),
              if (onTap != null)
                GestureDetector(
                  onTap: onTap,
                  child: Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: XColors.primary,
                  ),
                ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.redAccent, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sheetTile(String title, IconData icon, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: XColors.primary),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        onTap: onTap,
      );
}
