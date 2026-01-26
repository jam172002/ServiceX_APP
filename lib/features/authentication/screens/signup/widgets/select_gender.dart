import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart'; // your XColors

class GenderDropdown extends StatefulWidget {
  final ValueChanged<String?>? onChanged; // Add this

  const GenderDropdown({super.key, this.onChanged});

  @override
  State<GenderDropdown> createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<GenderDropdown> {
  String? selectedGender = 'Male';
  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: XColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Iconsax.woman,
              color: XColors.grey,
              size: 16,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: XColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: XColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: XColors.borderColor),
            ),
          ),
          dropdownColor: XColors.secondaryBG,
          style: TextStyle(color: XColors.grey, fontSize: 13),
          icon: const Icon(Iconsax.arrow_down_1, size: 15, color: XColors.grey),
          items: genders
              .map(
                (gender) => DropdownMenuItem<String>(
                  value: gender,
                  child: Text(
                    gender,
                    style: TextStyle(fontSize: 13, color: XColors.grey),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
            // Call external callback if provided
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
        ),
      ],
    );
  }
}
