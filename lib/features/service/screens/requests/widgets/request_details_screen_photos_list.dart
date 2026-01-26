import 'package:flutter/material.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/request_details_screen_photo_card.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class RequestPhotoList extends StatelessWidget {
  const RequestPhotoList({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = [
      XImages.serviceProvider02,
      XImages.serviceProvider02,
      XImages.serviceProvider02,
      XImages.serviceProvider02,
      XImages.serviceProvider02,
      XImages.serviceProvider02,
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return RequestPhotoCard(mediaPath: photos[index]);
        },
      ),
    );
  }
}
