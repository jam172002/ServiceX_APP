import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// =======================
/// BOOKING MODEL
/// =======================
class FixxerBookingModel {
  final String providerName;
  final String serviceTitle;
  final String description;
  final double amount;
  final DateTime dateTime;
  final String location;
  final List<String> images;
  bool isFavourite;
  bool isCancelled;

  FixxerBookingModel({
    required this.providerName,
    required this.serviceTitle,
    required this.description,
    required this.amount,
    required this.dateTime,
    required this.location,
    required this.images,
    this.isFavourite = false,
    this.isCancelled = false,
  });
}

/// =======================
/// BOOKING CARD
/// =======================
class FixxerBookingCard extends StatelessWidget {
  final FixxerBookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onFavouriteToggle;

  const FixxerBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onRemove,
    this.onFavouriteToggle,
  });

  /// ---------------- Status Logic ----------------
  String getStatus() {
    if (booking.isCancelled) return 'Cancelled';

    final now = DateTime.now();
    final bookingDate = booking.dateTime;

    if (bookingDate.isAfter(now)) {
      return 'Upcoming';
    } else if (bookingDate.day == now.day &&
        bookingDate.month == now.month &&
        bookingDate.year == now.year) {
      return 'Ongoing';
    } else if (bookingDate.isBefore(now)) {
      return 'Completed';
    }
    return 'Upcoming';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatus();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.lightTint.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------------- TOP ROW ----------------
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    booking.images.isNotEmpty
                        ? booking.images.first
                        : 'assets/images/service-provider2.jpg',
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            booking.providerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                status,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        booking.serviceTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: XColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ACTION BUTTONS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onFavouriteToggle,
                      child: Icon(
                        booking.isFavourite ? Iconsax.heart5 : Iconsax.heart,
                        size: 17,
                        color: booking.isFavourite ? Colors.red : XColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${booking.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// DESCRIPTION
            Text(
              booking.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: XColors.grey),
            ),

            const SizedBox(height: 12),

            /// IMAGES
            if (booking.images.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: booking.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        booking.images[index],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

            if (booking.images.isNotEmpty) const SizedBox(height: 12),

            /// DATE & LOCATION
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar_days,
                  size: 12,
                  color: XColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy • hh:mm a').format(booking.dateTime),
                  style: const TextStyle(fontSize: 11, color: XColors.grey),
                ),
                const Spacer(),
                const Icon(Iconsax.location, size: 12, color: XColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: XColors.grey),
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
