import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceProviderRatingBar extends StatelessWidget {
  final double initialRating;
  final double itemSize;
  final int itemCount;
  final bool allowHalfRating;
  final ValueChanged<double>? onRatingUpdate;

  const ServiceProviderRatingBar({
    super.key,
    this.initialRating = 0,
    this.itemSize = 20,
    this.itemCount = 5,
    this.allowHalfRating = true,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: allowHalfRating,
      itemCount: itemCount,
      itemSize: itemSize,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, index) =>
          const Icon(Icons.star, color: Colors.amber),
      unratedColor: Colors.grey[300],
      onRatingUpdate:
          onRatingUpdate ?? (rating) => print("New Rating: $rating"),
    );
  }
}
