import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class RequestScreenCard extends StatelessWidget {
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

  const RequestScreenCard({
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
  });

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'new':
      case 'newrequest':        return Colors.blue;
      case 'pending':           return Colors.blueGrey;
      case 'under review':
      case 'underreview':       return Colors.orange;
      case 'accepted':          return Colors.green;
      case 'in progress':
      case 'inprogress':
      case 'ongoing':           return Colors.purple;
      case 'completed':         return Colors.teal;
      case 'cancelled':         return Colors.red;
      default:                  return Colors.grey;
    }
  }

  Widget _buildImage() {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    const w = 130.0;
    const h = 148.0;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          imageUrl!,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(w, h, radius),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : _placeholder(w, h, radius, loading: true),
        ),
      );
    }

    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          imageAsset!,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(w, h, radius),
        ),
      );
    }

    return _placeholder(w, h, radius);
  }

  Widget _placeholder(double w, double h, BorderRadius radius,
      {bool loading = false}) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: w,
        height: h,
        color: XColors.grey.withValues(alpha: 0.15),
        child: loading
            ? const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
            : const Icon(Icons.image_not_supported_outlined,
            color: Colors.grey, size: 32),
      ),
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
              //? ── Left image ───────────────────────────────────────
              Stack(
                children: [
                  _buildImage(),
                  if (additionalImages > 0)
                    Positioned(
                      top: 6,
                      right: 6,
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

              //? ── Right details ────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags row
                      Row(
                        children: [
                          _Tag(label: category, color: XColors.primary),
                          const SizedBox(width: 4),
                          _Tag(label: status, color: statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: XColors.grey,
                        ),
                      ),

                      const Spacer(),

                      // Budget / job type / date / time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobType,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: XColors.primary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                budget,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
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
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}