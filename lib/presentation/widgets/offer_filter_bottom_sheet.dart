import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({super.key, required this.onApplyFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double? maxPrice = 200;
  int selectedDistance = 2; // km
  double selectedRating = 0.0; // ⭐ Fix → double for 4.5
  int estimatedTime = 60;

  final List<double> ratingOptions = [0.0, 3.0, 4.0, 4.5, 5.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: XColors.secondaryBG,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              "Filters",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // DISTANCE
            const Text(
              "Distance",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [1, 2, 5, 10].map((km) {
                return ChoiceChip(
                  selectedColor: XColors.primary.withValues(alpha: .15),
                  label: Text("$km km"),
                  selected: selectedDistance == km,
                  onSelected: (isSelected) {
                    if (isSelected) {
                      setState(() => selectedDistance = km);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // RATING
            const Text(
              "Minimum Rating",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: ratingOptions.map((rate) {
                String label = rate == 0
                    ? "Any"
                    : (rate % 1 == 0
                          ? rate.toInt().toString()
                          : rate.toString());

                return ChoiceChip(
                  selectedColor: Colors.amber.withValues(alpha: .25),

                  label: rate == 0
                      ? const Text("Any")
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(label),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                  selected: selectedRating == rate,
                  onSelected: (isSelected) {
                    if (isSelected) {
                      setState(() => selectedRating = rate);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // PRICE
            const Text(
              "Max Price",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: maxPrice!,
              min: 0,
              max: 500,
              divisions: 20,
              label: "\$${maxPrice!.toStringAsFixed(0)}",
              onChanged: (v) => setState(() => maxPrice = v),
            ),

            const SizedBox(height: 20),

            // TIME
            const Text(
              "Max Estimated Time",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$estimatedTime min"),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (estimatedTime > 10) {
                          setState(() => estimatedTime -= 10);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => estimatedTime += 10);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // APPLY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: XColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  widget.onApplyFilters({
                    "maxDistance": selectedDistance.toDouble(),
                    "minRating": selectedRating == 0 ? null : selectedRating,
                    "maxPrice": maxPrice,
                    "maxEstimatedTime": estimatedTime,
                  });

                  Get.back();
                },
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
