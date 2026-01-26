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
  final String imageAsset;
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
    required this.imageAsset,
    required this.onTap,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'under review':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Container(
          height: 148, // reduced from 175
          decoration: BoxDecoration(
            color: XColors.lightTint.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8), // slightly smaller
          ),
          child: Row(
            children: [
              //? ---------------- LEFT IMAGE ----------------
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Image.asset(
                      imageAsset,
                      width: 130,
                      height: 148,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (additionalImages > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: XColors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+$additionalImages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9, // smaller
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              //? ---------------- RIGHT DETAILS ----------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top tags
                      Row(
                        children: [
                          _Tag(label: category, color: XColors.primary),
                          const SizedBox(width: 4),
                          _Tag(label: status, color: getStatusColor(status)),
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

                      // Bottom row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Job type & budget
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

                          // Right: Date & Time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: XColors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: XColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Iconsax.location5,
                            size: 10, // smaller
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 9, // smaller
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

// Top row tags
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
          fontSize: 9, // smaller
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
