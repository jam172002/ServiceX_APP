import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class JobScreenCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String location;
  final String status;
  final String jobType;
  final String budget;
  final String date;
  final String time;
  final int additionalImages;

  /// Supply either a local asset path OR a network URL — not both.
  final String? imageAsset;
  final String? imageUrl;

  final VoidCallback onTap;

  /// When provided, a "View Quotes" button appears in the top-right corner.
  final VoidCallback? onQuotesTap;

  const JobScreenCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.jobType,
    required this.budget,
    required this.date,
    required this.time,
    required this.additionalImages,
    required this.onTap,
    this.imageAsset,
    this.imageUrl,
    this.onQuotesTap,
  });

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'new':
      case 'newrequest':   return Colors.blue;
      case 'pending':      return Colors.blueGrey;
      case 'under review':
      case 'underreview':  return Colors.orange;
      case 'accepted':     return Colors.green;
      case 'in progress':
      case 'inprogress':
      case 'ongoing':      return Colors.purple;
      case 'completed':    return Colors.teal;
      case 'cancelled':    return Colors.red;
      default:             return Colors.grey;
    }
  }

  Widget _buildImage() {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    const w = 130.0;
    const h = 148.0;

    Widget img;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      img = Image.network(
        imageUrl!, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (_, child, progress) =>
        progress == null ? child : _placeholder(loading: true),
      );
    } else if (imageAsset != null && imageAsset!.isNotEmpty) {
      img = Image.asset(
        imageAsset!, width: w, height: h, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      img = _placeholder();
    }

    return ClipRRect(borderRadius: radius, child: img);
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: 130, height: 148,
      color: XColors.grey.withValues(alpha: 0.15),
      child: loading
          ? const Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
          : const Icon(Icons.image_not_supported_outlined,
          color: Colors.grey, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Container(
          height: 148,
          decoration: BoxDecoration(
            color: XColors.lightTint.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [

              // ── Left image ─────────────────────────────────────────
              Stack(
                children: [
                  _buildImage(),
                  if (additionalImages > 0)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: XColors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+$additionalImages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Right details ──────────────────────────────────────
              Expanded(
                child: Padding(
                  // Reduced vertical padding from 12 → 10 to prevent overflow
                  padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Top row: category + status tags | Quotes button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Tag(label: category, color: XColors.primary),
                          const SizedBox(width: 4),
                          _Tag(label: status, color: statusColor),
                          const Spacer(),
                          if (onQuotesTap != null)
                            GestureDetector(
                              onTap: onQuotesTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: XColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Iconsax.document_text,
                                        size: 10, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text(
                                      'Quotes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Reduced gap from 6 → 4
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),

                      // Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: XColors.grey),
                      ),

                      const Spacer(),

                      // Budget / job type / date / time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(jobType,
                                  style: const TextStyle(
                                      fontSize: 10, color: XColors.primary)),
                              const SizedBox(height: 1),
                              Text(budget,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                      fontSize: 10, color: XColors.grey)),
                              const SizedBox(height: 2),
                              Text(time,
                                  style: const TextStyle(
                                      fontSize: 10, color: XColors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Iconsax.location5,
                              size: 10, color: Colors.black54),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}