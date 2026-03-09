import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/categories_n_subcategories/subcatagory_service_providers_screen.dart';
import 'package:servicex_client_app/presentation/widgets/popular_home_item_card.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class PopularHomeHorizontalList extends StatelessWidget {
  const PopularHomeHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data — replace with real subcategoryId when wiring to Firestore
    final cardData = {
      "title": "House Wirings",
      "mainCategory": "Electric",
      "description":
      "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium.",
      "price": "\$20/hour",
      "imagePath": XImages.serviceProviderBanner,
      "subcategoryId": "", // TODO: replace with real subcategory ID
    };

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        padding: const EdgeInsets.only(left: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) => PopularHomeCard(
          title: cardData["title"]!,
          mainCategory: cardData["mainCategory"]!,
          description: cardData["description"]!,
          price: cardData["price"]!,
          imagePath: cardData["imagePath"]!,
          onTap: () => Get.to(
                () => CatagoryServiceProviderScreen(
              screenTitle: 'Wiring and Rewiring',
              subcategoryId: cardData["subcategoryId"]!,
            ),
          ),
        ),
      ),
    );
  }
}