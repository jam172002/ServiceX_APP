// 4️⃣ DateTimeSection
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class DateTimeSection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const DateTimeSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onSelectDate,
          child: _dateInput(
            title: selectedDate == null
                ? "Select Date"
                // ignore: unnecessary_string_interpolations
                : "${selectedDate!.toLocal().toString().split(' ')[0]}",
            icon: Iconsax.calendar,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onSelectTime,
          child: _dateInput(
            title: selectedTime == null
                ? "Select Time"
                : selectedTime!.format(context),
            icon: Iconsax.clock,
          ),
        ),
      ],
    );
  }

  Widget _dateInput({required String title, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: XColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: XColors.primary),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}
