import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class TransactionTile extends StatelessWidget {
  final String dateTime;
  final String cardNumber;
  final double amount;
  final TransactionType type;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.dateTime,
    required this.cardNumber,
    required this.amount,
    required this.type,
    this.onTap,
  });

  String _maskedCard(String number) {
    final digitsOnly = number.replaceAll(' ', '');
    if (digitsOnly.length < 16) return number;
    return '**** **** **** ${digitsOnly.substring(12, 16)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCredit = type == TransactionType.credit;

    final Color amountColor = isCredit ? Colors.green : Colors.red;

    final IconData arrowIcon = isCredit
        ? LucideIcons.arrow_big_down
        : LucideIcons.arrow_big_up;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: XColors.borderColor.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Transaction Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateTime,
                  style: TextStyle(fontSize: 10, color: XColors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _maskedCard(cardNumber),
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            /// Amount + Direction Icon
            Row(
              children: [
                Text(
                  '${isCredit ? '+' : '-'}\$$amount',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(arrowIcon, color: amountColor, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
