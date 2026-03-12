import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/domain/enums/app_enums.dart';
import 'package:servicex_client_app/domain/models/booking_model.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String fixerName;
  final String fixerImageUrl;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.fixerName,
    required this.fixerImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: XColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + info + status badge ─────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixer avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: XColors.borderColor,
                  backgroundImage: fixerImageUrl.isNotEmpty
                      ? NetworkImage(fixerImageUrl)
                      : null,
                  child: fixerImageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),

                // Name + subcategory + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fixerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: XColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.subcategoryName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: XColors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.calendar,
                              size: 11, color: XColors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy · hh:mm a')
                                .format(booking.scheduledAt),
                            style: const TextStyle(
                                fontSize: 10, color: XColors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: XColors.borderColor),
            const SizedBox(height: 10),

            // ── Bottom row: location + budget ─────────────────
            Row(
              children: [
                const Icon(Iconsax.location, size: 12, color: XColors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.address.isNotEmpty
                        ? booking.address
                        : 'No location set',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: XColors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${booking.budgetMin}–\$${booking.budgetMax}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: XColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.booked:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}