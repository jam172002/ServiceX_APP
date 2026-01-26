// 5️⃣ BudgetSection
import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class BudgetSection extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final RangeValues budgetRange;
  final ValueChanged<RangeValues> onChanged;

  const BudgetSection({
    super.key,
    required this.minController,
    required this.maxController,
    required this.budgetRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Budget Range (\$)",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: budgetRange,
          min: 0,
          max: 1000,
          divisions: 100,
          activeColor: XColors.success,
          labels: RangeLabels(
            '\$${budgetRange.start.round()}',
            '\$${budgetRange.end.round()}',
          ),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true, // Makes the field more compact
                  contentPadding: EdgeInsets.fromLTRB(13, 8, 8, 8),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true, // Makes the field more compact
                  contentPadding: EdgeInsets.fromLTRB(13, 8, 8, 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
