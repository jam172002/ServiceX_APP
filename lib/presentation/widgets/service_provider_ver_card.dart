import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ServiceProviderVerCard extends StatelessWidget {
  final String name;
  final String location;
  final String image;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const ServiceProviderVerCard({
    super.key,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: XColors.lightTint.withValues(alpha: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- IMAGE --------------------
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(image, fit: BoxFit.cover),
            ),

            const SizedBox(height: 8),

            // -------------------- NAME + RATING --------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: XColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                Row(
                  children: [
                    Icon(Iconsax.star5, color: XColors.warning, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        color: XColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // -------------------- LOCATION --------------------
            Text(
              location,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: XColors.grey, fontSize: 11),
            ),

            const SizedBox(height: 8),

            // -------------------- INVITE BUTTON --------------------
            GestureDetector(
              onTap: onBook,
              child: Container(
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: XColors.primary,
                ),
                child: const Center(
                  child: Text(
                    'Book',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
