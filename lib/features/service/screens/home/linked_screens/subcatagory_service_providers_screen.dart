import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/common/widgets/containers/search_filter_container.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/service_provider_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/vipeeps/service_provider_screen_card.dart';

class CatagoryServiceProviderScreen extends StatelessWidget {
  final String screenTitle;

  const CatagoryServiceProviderScreen({super.key, required this.screenTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: screenTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const SearchWithFilter(horPadding: 16),
              const SizedBox(height: 20),

              ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ServiceProviderScreenCard(
                    category: 'Electrical',
                    name: 'Muhammad Sufyan',
                    rating: '4.5',
                    location: '3 km away',
                    amount: '\$20',
                    onTap: () {
                      Get.to(() => ServiceProviderProfileScreen());
                    },
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
