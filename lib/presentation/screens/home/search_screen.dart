import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/presentation/screens/home/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/screens/home/subcategories_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class SearchController extends GetxController {
  RxString searchQuery = ''.obs;

  final List<Map<String, dynamic>> allServices = [
    {'name': 'Gardening', 'icon': 'assets/icons/garden.png'},
    {'name': 'Plumbing', 'icon': 'assets/icons/plumber.png'},
    {'name': 'Cleaning', 'icon': 'assets/icons/cleaning.png'},
  ];

  final List<Map<String, dynamic>> allProviders = [
    {'name': 'Ali Services', 'image': 'assets/images/service-provider.jpg'},
    {'name': 'Ahmed Cleaners', 'image': 'assets/images/service-provider.jpg'},
  ];

  List<Map<String, dynamic>> get filteredServices {
    if (searchQuery.value.isEmpty) return [];
    return allServices
        .where(
          (service) => service['name'].toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> get filteredProviders {
    if (searchQuery.value.isEmpty) return [];
    return allProviders
        .where(
          (provider) => provider['name'].toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchController());

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    Widget buildServiceTile(Map<String, dynamic> service) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: () => Get.to(() => SubcategoriesScreen()),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
                radius: 25,
                child: SizedBox(
                  height: 22,
                  child: Image.asset(
                    service['icon'],
                    fit: BoxFit.contain,
                    color: XColors.primary,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(service['name']),
            ],
          ),
        ),
      );
    }

    Widget buildProviderTile(Map<String, dynamic> provider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: () => Get.to(() => ServiceProviderProfileScreen()),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: XColors.lightTint.withValues(alpha: 0.5),
                backgroundImage: AssetImage(provider['image']),
              ),
              const SizedBox(width: 12),
              Text(provider['name']),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: XAppBar(title: 'Search'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Search field with filter button
              SearchWithFilter(
                horPadding: 0,
                onFilterTap: () {},
                onChanged: (value) {
                  controller.searchQuery.value = value;
                },
              ),

              const SizedBox(height: 12),

              // Results
              Expanded(
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    // No input illustration
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Image.asset(
                          'assets/images/search-illustration.png',
                        ),
                      ),
                    );
                  }

                  final services = controller.filteredServices;
                  final providers = controller.filteredProviders;

                  if (services.isEmpty && providers.isEmpty) {
                    // No results found illustration
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Image.asset(
                              'assets/images/no-data-found.png',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No data Found!',
                            style: TextStyle(color: XColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      if (services.isNotEmpty) buildSectionTitle('Services'),
                      ...services.map((s) => buildServiceTile(s)),
                      if (services.isNotEmpty && providers.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: XColors.borderColor,
                          ),
                        ),
                      if (providers.isNotEmpty)
                        buildSectionTitle('Service Providers'),
                      ...providers.map((p) => buildProviderTile(p)),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
