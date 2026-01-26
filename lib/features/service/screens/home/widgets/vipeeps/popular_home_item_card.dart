import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// Reusable card
class PopularHomeCard extends StatelessWidget {
  final String title;
  final String mainCategory;
  final String description;
  final String price;
  final String imagePath;
  final VoidCallback? onTap;

  const PopularHomeCard({
    super.key,
    required this.title,
    required this.mainCategory,
    required this.description,
    required this.price,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: XColors.lightTint.withValues(alpha: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            SizedBox(height: 10),

            // Title and Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: XColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: XColors.lightTint.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mainCategory,
                    style: TextStyle(fontSize: 11, color: XColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Description
            Text(
              description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(color: XColors.grey, fontSize: 11),
            ),
            SizedBox(height: 10),

            // Price
            Row(
              children: [
                Text(
                  'Starting from ',
                  style: TextStyle(color: XColors.primary, fontSize: 11),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: XColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
