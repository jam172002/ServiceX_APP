import 'package:flutter/material.dart';
import 'package:servicex_client_app/common/widgets/containers/map_view_container.dart';
import 'package:servicex_client_app/common/widgets/headings/simple_heading.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/vipeeps/service_provider_ratingbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class ServiceProviderProfileBottomSection extends StatefulWidget {
  const ServiceProviderProfileBottomSection({super.key});

  @override
  State<ServiceProviderProfileBottomSection> createState() =>
      _ServiceProviderProfileBottomSectionState();
}

class _ServiceProviderProfileBottomSectionState
    extends State<ServiceProviderProfileBottomSection> {
  bool showAllReviews = false;

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Ali Khan',
      'date': '11/20/25',
      'rating': 4.5,
      'comment': 'Very professional and responsive. Highly recommended!',
      'likes': 15,
    },
    {
      'name': 'Sara Ahmed',
      'date': '11/18/25',
      'rating': 5,
      'comment': 'Outstanding service and quick response time.',
      'likes': 22,
    },
    {
      'name': 'Usman Riaz',
      'date': '11/15/25',
      'rating': 4,
      'comment': 'Good experience, but room for improvement in communication.',
      'likes': 8,
    },
    {
      'name': 'Hina Malik',
      'date': '11/12/25',
      'rating': 5,
      'comment': 'Excellent work! Very satisfied with the results.',
      'likes': 30,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapViewContainer(),

        SizedBox(height: 20),

        //? Heading
        XHeading(
          title: 'Recent Works',
          actionText: 'See all',
          onActionTap: () {},
          sidePadding: 0,
          showActionButton: false,
        ),
        SizedBox(height: 4),

        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 80,
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/profile-banner.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20),
        //? Heading
        XHeading(
          title: 'Rating & Reviews',
          actionText: 'See all',
          onActionTap: () {},
          sidePadding: 0,
          showActionButton: false,
        ),
        SizedBox(height: 10),
        // Rating summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  "3.5",
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                ServiceProviderRatingBar(
                  initialRating: 4.5,
                  itemSize: 25,
                  onRatingUpdate: (rating) {
                    print("User selected rating: $rating");
                  },
                ),
              ],
            ),

            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (index) {
                  int star = 5 - index;
                  double fraction = 0.0;
                  switch (star) {
                    case 5:
                      fraction = 0.7;
                      break;
                    case 4:
                      fraction = 0.3;
                      break;
                    case 3:
                      fraction = 0.0;
                      break;
                    case 2:
                      fraction = 0.2;
                      break;
                    case 1:
                      fraction = 0.1;
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text("$star"),
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
            showAllReviews ? reviews.length : reviews.length.clamp(0, 2),
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
                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: XColors.lighterTint,
                          child: Text(
                            review['name'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            // Date
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        //? rating bar
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: ServiceProviderRatingBar(
                            initialRating: 4.5,
                            itemSize: 15,
                            onRatingUpdate: (rating) {
                              print("User selected rating: $rating");
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Comment
                    Text(
                      review['comment'],
                      style: TextStyle(color: XColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // See more
        if (reviews.length > 2)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showAllReviews = !showAllReviews;
                });
              },
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
        // Invite now button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Your invite logic here
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Invite sent!')));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Book Now",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
