import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/authentication/screens/verification/fixxer_verification_status.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerProfessionalVerification extends StatefulWidget {
  const FixxerProfessionalVerification({super.key});

  @override
  State<FixxerProfessionalVerification> createState() =>
      _FixxerProfessionalVerificationState();
}

class _FixxerProfessionalVerificationState
    extends State<FixxerProfessionalVerification> {
  final PageController _controller = PageController();
  final ImagePicker _picker = ImagePicker();

  int _page = 0;
  final int totalPages = 3;

  XFile? idFront;
  XFile? idBack;

  final List<XFile> certifications = [];
  final List<XFile> licenses = [];

  String? idError;
  String? certError;

  // ---------- Image Picker ----------
  Future<XFile?> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: XColors.secondaryBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _PickerTile(
            icon: LucideIcons.camera,
            title: 'Camera',
            source: ImageSource.camera,
          ),
          _PickerTile(
            icon: LucideIcons.image,
            title: 'Gallery',
            source: ImageSource.gallery,
          ),
        ],
      ),
    );

    if (source == null) return null;
    return _picker.pickImage(source: source, imageQuality: 80);
  }

  // ---------- Validation ----------
  bool _validatePage() {
    setState(() {
      idError = null;
      certError = null;

      if (_page == 0 && (idFront == null || idBack == null)) {
        idError = 'Both front and back ID images are required';
      }

      if (_page == 1 && certifications.isEmpty) {
        certError = 'At least one certification is required';
      }
    });

    return idError == null && certError == null;
  }

  // ---------- Navigation ----------
  void _next() async {
    if (!_validatePage()) return;

    if (_page == totalPages - 1) {
      await _submitVerification();
      return;
    }

    setState(() => _page++);
    _controller.animateToPage(
      _page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _back() {
    if (_page == 0) return;
    setState(() => _page--);
    _controller.animateToPage(
      _page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // ---------- Submit ----------
  Future<void> _submitVerification() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Replace with real API
      await Future.delayed(const Duration(seconds: 2));

      Get.back();
      _showSuccessDialog();
    } catch (_) {
      Get.back();
      Get.snackbar(
        'Submission Failed',
        'Please try again',
        backgroundColor: XColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: XColors.primaryBG,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.circle_check,
                size: 44,
                color: XColors.success,
              ),
              const SizedBox(height: 14),
              const Text(
                'Verification Submitted',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your documents were submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: XColors.grey),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => FixxerVerificationStatusScreen());
                  },
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  child: const Text(
                    'View Status',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Professional Verification'),
      body: Column(
        children: [
          _progress(),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [_idPage(), _certificationPage(), _licensePage()],
            ),
          ),
          _buttons(),
        ],
      ),
    );
  }

  Widget _progress() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: List.generate(totalPages, (i) {
        return Expanded(
          child: Container(
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i <= _page
                  ? XColors.primary
                  : XColors.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    ),
  );

  Widget _buttons() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        if (_page > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _back,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: XColors.borderColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Back',
                style: TextStyle(color: XColors.grey, fontSize: 12),
              ),
            ),
          ),
        if (_page > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _next,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            child: Text(
              _page == totalPages - 1 ? 'Submit for Review' : 'Next',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );

  // ---------- Pages ----------
  Widget _idPage() => _pageWrapper(
    title: 'Upload ID',
    icon: LucideIcons.id_card,
    children: [
      _rectPicker('ID Front', idFront, (v) => setState(() => idFront = v)),
      _rectPicker('ID Back', idBack, (v) => setState(() => idBack = v)),
      if (idError != null) _errorText(idError!),
    ],
  );

  Widget _certificationPage() => _pageWrapper(
    title: 'Certifications',
    icon: LucideIcons.badge_check,
    children: [
      ...certifications.map(
        (f) => _rectPicker(
          'Certification',
          f,
          (_) {},
          removable: true,
          onRemove: () => setState(() => certifications.remove(f)),
        ),
      ),
      _addButton('Add Certification', () async {
        final img = await _pickImage();
        if (img != null) setState(() => certifications.add(img));
      }),
      if (certError != null) _errorText(certError!),
    ],
  );

  Widget _licensePage() => _pageWrapper(
    title: 'Licenses (Optional)',
    icon: LucideIcons.copyright,
    children: [
      ...licenses.map(
        (f) => _rectPicker(
          'License',
          f,
          (_) {},
          removable: true,
          onRemove: () => setState(() => licenses.remove(f)),
        ),
      ),
      _addButton('Add License', () async {
        final img = await _pickImage();
        if (img != null) setState(() => licenses.add(img));
      }),
    ],
  );

  // ---------- Reusable ----------
  Widget _pageWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: XColors.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _rectPicker(
    String label,
    XFile? image,
    Function(XFile?) onPick, {
    bool removable = false,
    VoidCallback? onRemove,
  }) => Column(
    children: [
      GestureDetector(
        onTap: () async {
          final img = await _pickImage();
          if (img != null) onPick(img);
        },
        child: Stack(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: XColors.borderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
                        size: 30,
                        color: XColors.success,
                      ),
                    )
                  : null,
            ),
            if (image != null && removable)
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const CircleAvatar(
                    radius: 11,
                    backgroundColor: XColors.danger,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11)),
      const SizedBox(height: 10),
    ],
  );

  Widget _addButton(String text, VoidCallback onTap) => OutlinedButton.icon(
    icon: const Icon(LucideIcons.plus, size: 16),
    label: Text(
      text,
      style: const TextStyle(fontSize: 12, color: XColors.grey),
    ),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: XColors.borderColor, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
    ),
    onPressed: onTap,
  );

  Widget _errorText(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: const TextStyle(color: XColors.danger, fontSize: 11),
    ),
  );
}

// ---------- Picker Tile ----------
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final ImageSource source;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: XColors.primary),
      title: Text(title, style: const TextStyle(color: XColors.grey)),
      onTap: () => Navigator.pop(context, source),
    );
  }
}
