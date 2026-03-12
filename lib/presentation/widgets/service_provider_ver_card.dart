import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ServiceProviderVerCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  // Provide one of these — [imageUrl] takes priority, [image] is asset fallback
  final String? imageUrl;
  final String? image;

  const ServiceProviderVerCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    this.onTap,
    this.onBook,
    this.imageUrl,
    this.image,
  }) : assert(imageUrl != null || image != null,
  'Provide at least imageUrl or image');

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
            // ── Image ─────────────────────────────────────────────
            Container(
              height: 130,
              width: double.infinity,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.hardEdge,
              child: _buildImage(),
            ),

            const SizedBox(height: 8),

            // ── Name + Rating ─────────────────────────────────────
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
                      rating.toStringAsFixed(1),
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

            // ── Location ──────────────────────────────────────────
            Text(
              location,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: XColors.grey, fontSize: 11),
            ),

            const SizedBox(height: 8),

            // ── Book button ───────────────────────────────────────
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

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => _avatar(),
      );
    }
    if (image != null && image!.isNotEmpty) {
      return Image.asset(image!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatar());
    }
    return _avatar();
  }

  Widget _avatar() => Container(
    color: Colors.grey.shade200,
    child: const Center(
        child: Icon(Icons.person, color: Colors.grey, size: 40)),
  );
}