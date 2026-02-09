import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class PaymentSection extends StatelessWidget {
  final String selectedPayment;
  final Function(String) onSelect;

  const PaymentSection({
    super.key,
    required this.selectedPayment,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final paymentOptions = [
      {
        "title": "Master Card",
        "subtitle": "**** **** **** 1234",
        "icon": "assets/icons/mastercard.png",
      },
      {
        "title": "Mobile Transfer",
        "subtitle": "Pay via your mobile banking",
        "icon": Iconsax.mobile,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...paymentOptions.map((option) {
          final isSelected = selectedPayment == option["title"];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onSelect(option["title"] as String),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? XColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? XColors.primary : XColors.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (option["icon"] is String)
                      Image.asset(
                        option["icon"] as String,
                        width: 36,
                        height: 24,
                        fit: BoxFit.contain,
                      )
                    else
                      Icon(
                        option["icon"] as IconData,
                        size: 28,
                        color: XColors.primary,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option["title"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option["subtitle"] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: XColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: option["title"] as String,

                      groupValue: selectedPayment,
                      activeColor: XColors.primary,
                      onChanged: (val) => onSelect(val!),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
