import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class RejectDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hintText;
  final String cancelText;
  final String submitText;
  final void Function(String) onSubmit;

  RejectDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hintText,
    this.cancelText = "Cancel",
    this.submitText = "Submit",
    required this.onSubmit,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.secondaryBG,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: XColors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: XColors.grey),
            ),
            const SizedBox(height: 14),

            // Input field
            TextField(
              controller: _controller,
              maxLines: 4,
              cursorColor: XColors.primary,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: XColors.primaryBG,
                contentPadding: const EdgeInsets.all(12),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: XColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: XColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    cancelText,
                    style: const TextStyle(color: XColors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    onSubmit(text);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.danger,
                    side: BorderSide(color: XColors.danger),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    submitText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
