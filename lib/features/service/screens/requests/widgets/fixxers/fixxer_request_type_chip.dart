import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerRequestTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FixxerRequestTypeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? XColors.primary.withValues(alpha: 0.12)
                : XColors.lightTint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? XColors.primary
                  : XColors.borderColor.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? XColors.primary : XColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
