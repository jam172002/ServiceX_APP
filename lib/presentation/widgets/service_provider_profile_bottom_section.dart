import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/bookings/create_booking_screen.dart';
import 'package:servicex_client_app/presentation/widgets/map_view_container.dart';
import 'package:servicex_client_app/presentation/widgets/simple_heading.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_ratingbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import '../../domain/models/fixer_model.dart';

class ServiceProviderProfileBottomSection extends StatefulWidget {
  /// The fixxer whose profile is being viewed — passed down from the profile screen.
  final FixerModel? fixxer;

  const ServiceProviderProfileBottomSection({
    super.key,
    this.fixxer,
  });

  @override
  State<ServiceProviderProfileBottomSection> createState() =>
      _ServiceProviderProfileBottomSectionState();
}

class _ServiceProviderProfileBottomSectionState
    extends State<ServiceProviderProfileBottomSection> {
  bool showAllReviews = false;

  // Dummy reviews — replace with real Firestore reviews when ready
  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Ali Khan',
      'date': '11/20/25',
      'rating': 4.5,
      'comment': 'Very professional and responsive. Highly recommended!',
    },
    {
      'name': 'Sara Ahmed',
      'date': '11/18/25',
      'rating': 5,
      'comment': 'Outstanding service and quick response time.',
    },
    {
      'name': 'Usman Riaz',
      'date': '11/15/25',
      'rating': 4,
      'comment': 'Good experience, but room for improvement in communication.',
    },
    {
      'name': 'Hina Malik',
      'date': '11/12/25',
      'rating': 5,
      'comment': 'Excellent work! Very satisfied with the results.',
    },
  ];

  void _bookNow() {
    final f = widget.fixxer;
    if (f == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fixer info not available')),
      );
      return;
    }
    Get.to(() => CreateBookingScreen(fixer: f));
  }

  @override
  Widget build(BuildContext context) {
    // Use real rating/totalReviews if fixxer is provided
    final displayRating =
        widget.fixxer?.rating.toStringAsFixed(1) ?? '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MapViewContainer(),

        const SizedBox(height: 20),

        // ── Recent Works ───────────────────────────────────────────────────
        XHeading(
          title: 'Recent Works',
          actionText: 'See all',
          onActionTap: () {},
          sidePadding: 0,
          showActionButton: false,
        ),
        const SizedBox(height: 4),

        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.fixxer?.serviceImages.isNotEmpty == true
                ? widget.fixxer!.serviceImages.length
                : 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final imageUrl = widget.fixxer?.serviceImages.isNotEmpty == true
                  ? widget.fixxer!.serviceImages[index]
                  : null;
              return SizedBox(
                height: 80,
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                      : _placeholderImage(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── Rating & Reviews ───────────────────────────────────────────────
        XHeading(
          title: 'Rating & Reviews',
          actionText: 'See all',
          onActionTap: () {},
          sidePadding: 0,
          showActionButton: false,
        ),
        const SizedBox(height: 10),

        // Rating summary row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  displayRating,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                ServiceProviderRatingBar(
                  initialRating: widget.fixxer?.rating ?? 0.0,
                  itemSize: 25,
                  onRatingUpdate: (_) {},
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  // Placeholder fractions — replace with real breakdown if available
                  const fractions = {5: 0.7, 4: 0.3, 3: 0.0, 2: 0.2, 1: 0.1};
                  final fraction =
                      fractions[star]?.toDouble() ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$star'),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: fraction,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: XColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Reviews list
        Column(
          children: List.generate(
            showAllReviews
                ? reviews.length
                : reviews.length.clamp(0, 2),
                (index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: XColors.secondaryBG,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: XColors.borderColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: XColors.lighterTint,
                          child: Text(
                            (review['name'] as String)[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              review['date'] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ServiceProviderRatingBar(
                            initialRating:
                            (review['rating'] as num).toDouble(),
                            itemSize: 15,
                            onRatingUpdate: (_) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'] as String,
                      style:
                      const TextStyle(color: XColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // See more / less
        if (reviews.length > 2)
          Center(
            child: GestureDetector(
              onTap: () =>
                  setState(() => showAllReviews = !showAllReviews),
              child: Text(
                showAllReviews ? 'See less' : 'See more',
                style: const TextStyle(
                  color: XColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

        const SizedBox(height: 30),

        // ── Book Now button ────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _bookNow,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: XColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() => Container(
    color: XColors.lightTint.withValues(alpha: 0.4),
    child: const Icon(Icons.image_outlined,
        color: XColors.grey, size: 28),
  );
}