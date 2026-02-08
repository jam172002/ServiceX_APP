import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/vipeeps/service_provider_ratingbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerReviewsScreen extends StatefulWidget {
  const FixxerReviewsScreen({super.key});

  @override
  State<FixxerReviewsScreen> createState() => _FixxerReviewsScreenState();
}

class _FixxerReviewsScreenState extends State<FixxerReviewsScreen> {
  String selectedFilter = 'Recent reviews';

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Ali Khan',
      'date': DateTime(2025, 11, 20),
      'rating': 4.5,
      'comment': 'Very professional and responsive. Highly recommended!',
    },
    {
      'name': 'Sara Ahmed',
      'date': DateTime(2025, 11, 18),
      'rating': 5.0,
      'comment': 'Outstanding service and quick response time.',
    },
    {
      'name': 'Usman Riaz',
      'date': DateTime(2025, 11, 15),
      'rating': 4.0,
      'comment': 'Good experience, but communication can improve.',
    },
    {
      'name': 'Hina Malik',
      'date': DateTime(2025, 11, 12),
      'rating': 5.0,
      'comment': 'Excellent work! Very satisfied.',
    },
    {
      'name': 'Ahmed Noor',
      'date': DateTime(2025, 11, 10),
      'rating': 3.5,
      'comment': 'Decent service overall.',
    },
    {
      'name': 'Ayesha Khan',
      'date': DateTime(2025, 11, 8),
      'rating': 4.8,
      'comment': 'Very skilled and polite.',
    },
    {
      'name': 'Bilal Hussain',
      'date': DateTime(2025, 11, 6),
      'rating': 3.0,
      'comment': 'Work was okay, delivery was slow.',
    },
    {
      'name': 'Fatima Ali',
      'date': DateTime(2025, 11, 3),
      'rating': 4.9,
      'comment': 'Amazing experience. Will book again!',
    },
  ];

  List<Map<String, dynamic>> get sortedReviews {
    final list = [...reviews];

    if (selectedFilter == 'Highest rating') {
      list.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (selectedFilter == 'Lowest rating') {
      list.sort((a, b) => a['rating'].compareTo(b['rating']));
    } else {
      list.sort((a, b) => b['date'].compareTo(a['date']));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: XAppBar(title: 'Client Reviews'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Rating Summary
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      "4.6",
                      style: TextStyle(
                        color: XColors.black,
                        fontSize: width * 0.14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ServiceProviderRatingBar(
                      initialRating: 4.6,
                      itemSize: 16,
                      onRatingUpdate: (_) {},
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "3536 Reviews",
                      style: TextStyle(color: XColors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      return _ratingDistribution(star);
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Filter Dropdown
            DropdownButton<String>(
              value: selectedFilter,
              underline: const SizedBox(),
              dropdownColor: XColors.secondaryBG,
              isExpanded: true,
              icon: Icon(
                LucideIcons.chevron_down,
                size: 16,
                color: XColors.black,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Recent reviews',
                  child: Text('Recent reviews'),
                ),
                DropdownMenuItem(
                  value: 'Highest rating',
                  child: Text('Highest rating'),
                ),
                DropdownMenuItem(
                  value: 'Lowest rating',
                  child: Text('Lowest rating'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            /// Reviews List
            ListView.builder(
              itemCount: sortedReviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final review = sortedReviews[index];
                return _reviewCard(review);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingDistribution(int star) {
    final fractions = {5: 0.7, 4: 0.3, 3: 0.0, 2: 0.2, 1: 0.1};

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 14, child: Text("$star")),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 8, color: Colors.grey.shade300),
                  FractionallySizedBox(
                    widthFactor: fractions[star]!,
                    child: Container(height: 8, color: XColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: XColors.secondaryBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: XColors.borderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${review['date'].month}/${review['date'].day}/${review['date'].year}",
                    style: TextStyle(fontSize: 11, color: XColors.grey),
                  ),
                ],
              ),
              const Spacer(),
              ServiceProviderRatingBar(
                initialRating: review['rating'],
                itemSize: 14,
                onRatingUpdate: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'],
            style: TextStyle(color: XColors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
