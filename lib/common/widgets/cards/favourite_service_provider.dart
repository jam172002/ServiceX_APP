import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FavouriteServiceProviderAvatar extends StatelessWidget {
  final String name;
  final String location;
  final String image;
  final double rating;
  final VoidCallback? onTap;

  const FavouriteServiceProviderAvatar({
    super.key,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            // ------------------ AVATAR ------------------
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: XColors.lightTint,
                  backgroundImage: AssetImage(image),
                ),

                // ------------------ RATING BADGE ------------------
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: XColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.star5, size: 12, color: XColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ------------------ NAME ------------------
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: XColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            // ------------------ LOCATION ------------------
            Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: XColors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
