import 'dart:io';
import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String service;
  final String? subType;
  final String details;
  final String location;
  final String date;
  final String time;
  final int budgetMin;
  final int budgetMax;
  final String payment;
  final List<File> images;
  final bool forAll;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.service,
    this.subType,
    required this.details,
    required this.location,
    required this.date,
    required this.time,
    required this.budgetMin,
    required this.budgetMax,
    required this.payment,
    required this.images,
    required this.forAll,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: XColors.secondaryBG,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Confirm Job'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: $service'),
            Text('Sub-Type: ${subType ?? "-"}'),
            Text('Date: $date'),
            Text('Time: $time'),
            Text('Budget: $budgetMin - $budgetMax'),
            Text('Payment: $payment'),
            Text('Location: $location'),
            const SizedBox(height: 10),
            Text('Details: $details'),
            if (images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(
                      images[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'Job Type: ${forAll ? "Open for All" : "Personal Request"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
