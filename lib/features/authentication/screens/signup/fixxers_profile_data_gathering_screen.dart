import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/common/widgets/dialogs/simple_alert_dialog.dart';
import 'package:servicex_client_app/features/authentication/screens/permissions/permission_screen.dart';
import 'package:servicex_client_app/features/service/screens/navigation/fixxer_navigation.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class FixxersProfileDataGatheringScreen extends StatefulWidget {
  const FixxersProfileDataGatheringScreen({super.key});

  @override
  State<FixxersProfileDataGatheringScreen> createState() =>
      _FixxersProfileDataGatheringScreenState();
}

class _FixxersProfileDataGatheringScreenState
    extends State<FixxersProfileDataGatheringScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  int _currentPage = 0;
  final int totalPages = 2; // 🔹 ID page removed

  // ---------- Page 0: Images ----------
  XFile? profileImage;
  XFile? bannerImage;

  // ---------- Page 1: Services ----------
  final List<String> serviceCategories = [
    'Electrician',
    'Plumber',
    'AC Technician',
    'Carpenter',
  ];

  final Map<String, List<String>> subCategoryMap = {
    'Electrician': ['Wiring', 'Fan Repair', 'Switch Installation', 'UPS Setup'],
    'Plumber': ['Pipe Fixing', 'Leak Repair', 'Bathroom Fitting'],
    'AC Technician': ['Installation', 'Repair', 'Gas Refill'],
    'Carpenter': ['Furniture', 'Door Repair', 'Cabinet'],
  };

  String? selectedCategory;
  final Set<String> selectedSubcategories = {};
  final TextEditingController chargesController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    chargesController.dispose();
    super.dispose();
  }

  // ------------------ IMAGE PICKER ------------------
  Future<XFile?> _pickImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: XColors.primary),
              title: const Text(
                'Camera',
                style: TextStyle(color: XColors.black),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: XColors.primary),
              title: const Text(
                'Gallery',
                style: TextStyle(color: XColors.black),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );

      if (source == null) return null;
      return await _picker.pickImage(source: source, imageQuality: 80);
    } catch (_) {
      await _showMessage('Unable to pick image. Please try again.');
      return null;
    }
  }

  Future<void> _showMessage(String msg) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        actionsPadding: EdgeInsets.zero,
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ------------------ VALIDATION ------------------
  bool _isPageValid(int index) {
    switch (index) {
      case 0:
        return profileImage != null && bannerImage != null;
      case 1:
        return selectedCategory != null &&
            selectedSubcategories.isNotEmpty &&
            chargesController.text.isNotEmpty;
      default:
        return false;
    }
  }

  // ------------------ NAVIGATION ------------------
  void _next() async {
    if (!_isPageValid(_currentPage)) {
      if (_currentPage == 0) {
        if (profileImage == null) {
          await _showMessage('Please select a profile image.');
          return;
        }
        if (bannerImage == null) {
          await _showMessage('Please select a banner image.');
          return;
        }
      }

      if (_currentPage == 1) {
        if (selectedCategory == null) {
          await _showMessage('Please select your main service.');
          return;
        }
        if (selectedSubcategories.isEmpty) {
          await _showMessage('Please select at least one subcategory.');
          return;
        }
        if (chargesController.text.isEmpty) {
          await _showMessage('Please enter your charges.');
          return;
        }
      }
    }

    if (_currentPage == totalPages - 1) {
      Get.dialog(
        SimpleDialogWidget(
          message: "Profile setup completed!",
          icon: Iconsax.tick_circle,
          iconColor: Colors.green,
          buttonText: "Continue",
          onOk: () {
            Get.off(
              () => PermissionScreen(
                title: 'Get Notified!',
                subtitle:
                    'Enable notifications to stay updated with new requests, offers, and booking reminders.',
                allowButtonText: 'Allow',
                illustration: Image.asset(XImages.allowNotifications),
                showDenyButton: true,
                onAllow: () => Get.off(() => FixxerNavigation()),
              ),
            );
          },
        ),
      );
      return;
    }

    setState(() => _currentPage++);
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _back() {
    if (_currentPage == 0) return;
    setState(() => _currentPage--);
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final allowSwipe = _isPageValid(_currentPage);

    return Scaffold(
      appBar: XAppBar(title: 'Profile Setup'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(totalPages, (i) {
                final isActive = i <= _currentPage;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? XColors.primary
                          : XColors.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: allowSwipe
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [_imagesPage(), _servicePage()],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: XColors.secondaryBG,
                        side: BorderSide(color: XColors.borderColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _back,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: XColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: XColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _currentPage == totalPages - 1 ? 'Finish' : 'Next',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ PAGES ------------------
  Widget _imagesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _circularImagePicker(
            'Select profile picture',
            profileImage,
            (img) => setState(() => profileImage = img),
          ),
          const SizedBox(height: 20),
          _rectangularImagePicker(
            'Select image for your profile banner',
            bannerImage,
            (img) => setState(() => bannerImage = img),
          ),
        ],
      ),
    );
  }

  Widget _servicePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Main Service',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            dropdownColor: XColors.secondaryBG,
            hint: const Text(
              'Select your service type',
              style: TextStyle(fontSize: 12, color: XColors.grey),
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: serviceCategories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
                selectedSubcategories.clear();
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Subcategories',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: (subCategoryMap[selectedCategory] ?? [])
                .map(
                  (e) => FilterChip(
                    label: Text(e),
                    selected: selectedSubcategories.contains(e),
                    onSelected: (v) {
                      setState(() {
                        v
                            ? selectedSubcategories.add(e)
                            : selectedSubcategories.remove(e);
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Charges per hour',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: chargesController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              hintText: 'e.g. 15.00',
              prefixText: '\$ ',
              prefixStyle: TextStyle(color: Colors.green),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ IMAGE PICKERS ------------------
  Widget _circularImagePicker(
    String label,
    XFile? image,
    Function(XFile?) onPick,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final img = await _pickImage();
            if (img != null) onPick(img);
          },
          child: CircleAvatar(
            radius: 50,
            backgroundColor: XColors.borderColor.withValues(alpha: 0.2),
            backgroundImage: image != null ? FileImage(File(image.path)) : null,
            child: image == null
                ? const Icon(Iconsax.user, size: 30, color: XColors.success)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _rectangularImagePicker(
    String label,
    XFile? image,
    Function(XFile?) onPick,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final img = await _pickImage();
            if (img != null) onPick(img);
          },
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: XColors.borderColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              image: image != null
                  ? DecorationImage(
                      image: FileImage(File(image.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? const Center(
                    child: Icon(
                      LucideIcons.image_plus,
                      size: 35,
                      color: XColors.success,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
