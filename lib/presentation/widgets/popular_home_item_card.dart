import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// Reusable card — supports both network [imageUrl] and asset [imagePath].
/// If [imageUrl] is provided and non-empty it takes priority over [imagePath].
class PopularHomeCard extends StatelessWidget {
  final String title;
  final String mainCategory;
  final String description;
  final String price;
  final String imagePath;       // asset fallback
  final String? imageUrl;       // network image (optional)
  final VoidCallback? onTap;

  const PopularHomeCard({
    super.key,
    required this.title,
    required this.mainCategory,
    required this.description,
    required this.price,
    required this.imagePath,
    this.imageUrl,
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
            // ── Image ─────────────────────────────────────────────
            Container(
              height: 130,
              width: double.infinity,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.hardEdge,
              child: _buildImage(),
            ),
            const SizedBox(height: 10),

            // ── Title + Category badge ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: XColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: XColors.lightTint.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mainCategory,
                    style:
                    const TextStyle(fontSize: 11, color: XColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Description ───────────────────────────────────────
            Text(
              description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(color: XColors.grey, fontSize: 11),
            ),
            const SizedBox(height: 10),

            // ── Price ─────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Starting from ',
                  style: TextStyle(color: XColors.primary, fontSize: 11),
                ),
                Text(
                  price,
                  style: const TextStyle(
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

  Widget _buildImage() {
    // Use network image if available
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) =>
            Image.asset(imagePath, fit: BoxFit.cover),
      );
    }
    // Fall back to asset
    return Image.asset(imagePath, fit: BoxFit.cover);
  }
}