import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/check_offer_screen_card.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/offer_filter_bottom_sheet.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class CheckOfferScreen extends StatefulWidget {
  const CheckOfferScreen({super.key});

  @override
  State<CheckOfferScreen> createState() => _CheckOfferScreenState();
}

class _CheckOfferScreenState extends State<CheckOfferScreen> {
  List<Map<String, dynamic>> offersData = [
    {
      "name": "Ali Raza",
      "timeAgo": "10 min ago",
      "distance": "1.5 km away",
      "rating": 4.8,
      "price": "\$120",
      "estimatedTime": "1 hour",
      "dateTime": "2025-12-02 14:00",
      "description": "Quick and professional service guaranteed.",
    },
    {
      "name": "Hamza Khan",
      "timeAgo": "22 min ago",
      "distance": "3 km away",
      "rating": 4.6,
      "price": "\$90",
      "estimatedTime": "1.5 hours",
      "dateTime": "2025-12-03 16:30",
      "description": "Can fix all types of pipe leakages.",
    },
    {
      "name": "Hamza Khan",
      "timeAgo": "22 min ago",
      "distance": "3 km away",
      "rating": 4.6,
      "price": "\$90",
      "estimatedTime": "1.5 hours",
      "dateTime": "2025-12-03 16:30",
      "description": "Can fix all types of pipe leakages.",
    },
  ];

  List<Map<String, dynamic>> filteredOffers = [];

  @override
  void initState() {
    super.initState();
    filteredOffers = List.from(offersData);
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      FilterBottomSheet(
        onApplyFilters: (filters) {
          setState(() {
            filteredOffers = offersData.where((offer) {
              double distance = double.parse(offer["distance"].split(" ")[0]);
              double rating = offer["rating"];
              double price = double.parse(
                offer["price"].replaceAll(RegExp(r'[^\d.]'), ''),
              );

              int estTime = (offer["estimatedTime"].contains("hour"))
                  ? (double.parse(offer["estimatedTime"].split(" ")[0]) * 60)
                        .toInt()
                  : int.parse(offer["estimatedTime"].split(" ")[0]);

              if (filters["maxDistance"] != null &&
                  distance > filters["maxDistance"]) {
                return false;
              }

              if (filters["minRating"] != null &&
                  rating < filters["minRating"]) {
                return false;
              }

              if (filters["maxPrice"] != null && price > filters["maxPrice"]) {
                return false;
              }

              if (filters["maxEstimatedTime"] != null &&
                  estTime > filters["maxEstimatedTime"]) {
                return false;
              }

              return true;
            }).toList();
          });
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Received Offers',
          style: TextStyle(
            color: XColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Iconsax.setting_4, color: XColors.black, size: 23),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filteredOffers.length,
          itemBuilder: (context, index) {
            final offer = filteredOffers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CheckOfferScreenCard(
                name: offer["name"],
                profession: "Electrician",
                timeAgo: offer["timeAgo"],
                distance: offer["distance"],
                rating: offer["rating"],
                price: offer["price"],
                estimatedTime: offer["estimatedTime"],
                dateTime: offer["dateTime"],
                description: offer["description"],
              ),
            );
          },
        ),
      ),
    );
  }
}
