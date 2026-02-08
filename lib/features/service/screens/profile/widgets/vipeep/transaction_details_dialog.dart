import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

void showTransactionDetailsDialog(
  BuildContext context, {
  required TransactionCase caseType,
  required String titleName,
  required String dateTime,
  required String location,
  required String avatarAsset,
  bool isCancelled = false,
}) {
  final bool isSent = caseType == TransactionCase.sent;
  final bool isReceived = caseType == TransactionCase.received;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Transaction Details',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      final value = Curves.easeOut.transform(animation.value);

      return Opacity(
        opacity: value,
        child: Transform.scale(
          scale: value,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCancelled
                            ? 'Transferred back'
                            : isSent
                            ? 'Sent to'
                            : 'Received for',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Avatar + Name + Status
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: AssetImage(avatarAsset),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCancelled ? 'Your Wallet' : titleName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _statusBadge(isCancelled),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// Transaction Date & Time
                  _infoRow(title: 'Transaction time', value: dateTime),

                  const SizedBox(height: 10),

                  /// Job / Booking Date
                  _infoRow(
                    title: isSent ? 'Job completed' : 'Booking date',
                    value: dateTime,
                  ),

                  const SizedBox(height: 10),

                  /// Location
                  _infoRow(title: 'Location', value: location),

                  const SizedBox(height: 16),

                  /// Action
                  _actionButton(
                    icon: Icons.download_outlined,
                    label: 'Download receipt',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _statusBadge(bool isCancelled) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isCancelled
          ? Colors.red.withValues(alpha: 0.1)
          : Colors.green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      isCancelled ? 'Cancelled' : 'Completed',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isCancelled ? Colors.red : Colors.green,
      ),
    ),
  );
}

Widget _infoRow({required String title, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

Widget _actionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
