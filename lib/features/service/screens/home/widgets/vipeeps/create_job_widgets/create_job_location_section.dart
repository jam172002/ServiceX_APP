// 3️⃣ LocationSection
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class LocationSection extends StatelessWidget {
  final String location;
  final VoidCallback onEdit;

  const LocationSection({
    super.key,
    required this.location,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Location",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            InkWell(
              onTap: onEdit,
              child: Text(
                "Change",
                style: TextStyle(
                  color: XColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(Iconsax.location, color: XColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(location, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
