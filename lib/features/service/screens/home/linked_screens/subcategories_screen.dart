import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/common/widgets/containers/search_filter_container.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/service_provider_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/subcatagory_service_providers_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/vipeeps/single_subcatagory.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class SubcategoriesScreen extends StatelessWidget {
  const SubcategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy provider template with dynamic tap actions
    final providerTemplate = {
      "name": "M Sufyan",
      "location": "Bahawalpur, Pakistan",
      "rating": 4.7,
      "image": XImages.serviceProvider,

      // Dynamic tap functions
      "onTap": () => Get.to(() => ServiceProviderProfileScreen()),
      "onInvite": () => print("Invite Tap: M Sufyan"),
    };

    // Generate list of 8 providers
    final providers = List.generate(
      8,
      (_) => Map<String, dynamic>.from(providerTemplate),
    );

    // Subcategory titles
    final subcategories = [
      "Wiring & Rewiring",
      "AC Repair",
      "Plumbing",
      "Car Wash",
    ];

    return Scaffold(
      appBar: XAppBar(title: 'Electrical'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SearchWithFilter(horPadding: 16),
              const SizedBox(height: 20),

              ...subcategories.map(
                (title) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SingleSubCategory(
                    title: title,
                    actionText: "See all",

                    // Navigate to provider listing screen
                    onActionTap: () => Get.to(
                      () => const CatagoryServiceProviderScreen(
                        screenTitle: 'Wiring and Rewiring',
                      ),
                    ),

                    // Pass list with embedded tap functions
                    providers: providers,
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
