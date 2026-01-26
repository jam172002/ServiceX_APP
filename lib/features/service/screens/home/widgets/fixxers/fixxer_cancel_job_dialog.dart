import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

void fixxerShowCancelRequestDialog(
  BuildContext context, {
  required Function(String reason) onConfirm,
}) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Cancel Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter reason for cancellation',
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: XColors.grey,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Back', style: TextStyle(color: XColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: XColors.danger,
              side: const BorderSide(color: XColors.danger),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            onPressed: () {
              if (reasonController.text.isEmpty) return;
              onConfirm(reasonController.text.trim());
              Get.back();
            },
            child: const Text('Confirm', style: TextStyle(fontSize: 13)),
          ),
        ],
      );
    },
  );
}
