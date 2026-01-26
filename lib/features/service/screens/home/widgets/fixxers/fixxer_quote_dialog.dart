import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

void showQuoteDialog(
  BuildContext context, {
  bool isEdit = false,
  String? initialPrice,
  DateTime? initialDeadline,
  required Function(String price, DateTime deadline) onSubmit,
}) {
  final formKey = GlobalKey<FormState>();

  final priceController = TextEditingController(text: initialPrice ?? '');
  final deadlineController = TextEditingController(
    text: initialDeadline == null
        ? ''
        : '${initialDeadline.day}/${initialDeadline.month}/${initialDeadline.year}',
  );

  DateTime? selectedDate = initialDeadline;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          isEdit ? 'Edit Quote' : 'Send Quote',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(color: XColors.success),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deadlineController,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deadline is required';
                  }
                  return null;
                },
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        selectedDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    deadlineController.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select deadline',
                  suffixIcon: const Icon(Iconsax.calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: XColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: XColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSubmit(priceController.text.trim(), selectedDate!);
              Get.back();
            },
            child: Text(
              isEdit ? 'Update' : 'Send',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      );
    },
  );
}
