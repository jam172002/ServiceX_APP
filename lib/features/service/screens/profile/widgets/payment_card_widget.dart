import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class PaymentCardWidget extends StatelessWidget {
  final String number;
  final String name;
  final String expiry;
  final String brand;
  final bool isDefault;

  const PaymentCardWidget({
    super.key,
    required this.number,
    required this.name,
    required this.expiry,
    required this.brand,
    required this.isDefault,
  });

  // Mask first 12 digits and keep spaces
  String masked(String number) {
    String digitsOnly = number.replaceAll(' ', '');
    if (digitsOnly.length < 16) return number; // fallback
    return '**** **** **** ${digitsOnly.substring(12, 16)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDefault
              ? LinearGradient(
                  colors: [
                    XColors.success.withValues(alpha: 0.85),
                    XColors.success.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    XColors.lightTint.withValues(alpha: 0.85),
                    XColors.lightTint.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          border: isDefault
              ? Border.all(
                  color: XColors.black.withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: XColors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: XColors.black,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (brand == 'VISA')
                  Image.asset('assets/icons/visa.png', width: 36)
                else if (brand == 'MASTERCARD')
                  Image.asset('assets/icons/mastercard.png', width: 36),
              ],
            ),
            const Spacer(),
            Text(
              masked(number),
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  expiry,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
