import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerHomeBookingCard extends StatefulWidget {
  final String providerName;
  final String serviceTitle;
  final String description;
  final double amount;
  final DateTime dateTime;
  final String location;
  final List<String> images;
  final bool isFavourite;
  final bool isCancelled;
  final VoidCallback onTap;

  const FixxerHomeBookingCard({
    super.key,
    required this.providerName,
    required this.serviceTitle,
    required this.description,
    required this.amount,
    required this.dateTime,
    required this.location,
    required this.images,
    this.isFavourite = false,
    this.isCancelled = false,
    required this.onTap,
  });

  @override
  State<FixxerHomeBookingCard> createState() => _FixxerHomeBookingCardState();
}

class _FixxerHomeBookingCardState extends State<FixxerHomeBookingCard> {
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isFavourite;
  }

  void _toggleFavourite() {
    setState(() {
      isFavourite = !isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainImage = widget.images.isNotEmpty
        ? widget.images.first
        : 'assets/images/profile-banner.jpg';
    final remainingImages = widget.images.length > 1
        ? widget.images.length - 1
        : 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: XColors.lightTint.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN IMAGE + HEART + "+remaining"
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    mainImage,
                    width: 210,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Heart icon
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: _toggleFavourite,
                    child: Icon(
                      isFavourite ? Iconsax.heart5 : Iconsax.heart,
                      color: isFavourite ? Colors.red : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                // +remaining overlay
                if (remainingImages > 0)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+$remainingImages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // PROVIDER + SERVICE
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage(
                    widget.images.isNotEmpty ? widget.images.first : '',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.serviceTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: XColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // DESCRIPTION
            Text(
              widget.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: XColors.grey),
            ),
            const SizedBox(height: 6),

            // AMOUNT & STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isCancelled
                        ? Colors.red.withValues(alpha: 0.12)
                        : Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.isCancelled ? 'Cancelled' : 'Upcoming',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: widget.isCancelled ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // LOCATION
            Row(
              children: [
                const Icon(Iconsax.location, size: 12, color: XColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.location,
                    style: const TextStyle(fontSize: 11, color: XColors.grey),
                    overflow: TextOverflow.ellipsis,
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
