import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/features/service/models/fixxer_job_request_model.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class FixxerJobRequestCard extends StatefulWidget {
  final FixxerJobRequestModel job;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isFavourite;

  const FixxerJobRequestCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onRemove,
    this.isFavourite = false,
  });

  @override
  State<FixxerJobRequestCard> createState() => _FixxerJobRequestCardState();
}

class _FixxerJobRequestCardState extends State<FixxerJobRequestCard> {
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isFavourite; // Initialize from widget
  }

  void _toggleFavourite() {
    setState(() => isFavourite = !isFavourite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavourite ? 'Added to favourites' : 'Removed from favourites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: XColors.secondaryBG,
        title: const Text('Remove Request'),
        content: const Text(
          'Are you sure you want to remove this job request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRemove?.call();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job request removed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final isDirect = job.type == FixxerJobRequestType.direct;

    return GestureDetector(
      onTap: widget.onTap,
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
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    'assets/images/service-provider2.jpg',
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
                            job.clientName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDirect
                                  ? Colors.teal.withValues(alpha: 0.12)
                                  : Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isDirect ? 'Direct' : 'Open',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDirect ? Colors.teal : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        job.serviceTitle,
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFavourite,
                          child: Icon(
                            isFavourite ? Iconsax.heart5 : Iconsax.heart,
                            size: 17,
                            color: isFavourite ? Colors.red : XColors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _confirmRemove,
                          child: const Icon(
                            LucideIcons.thumbs_down,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${job.minBudget} - \$${job.maxBudget}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// DESCRIPTION
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: XColors.grey),
            ),

            const SizedBox(height: 12),

            /// IMAGES
            if (job.images.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        job.images[index],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

            if (job.images.isNotEmpty) const SizedBox(height: 12),

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
                  DateFormat('dd MMM yyyy • hh:mm a').format(job.dateTime),
                  style: const TextStyle(fontSize: 11, color: XColors.grey),
                ),
                const Spacer(),
                const Icon(Iconsax.location, size: 12, color: XColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
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
