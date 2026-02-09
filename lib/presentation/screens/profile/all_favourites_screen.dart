import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/common_appbar.dart';
import 'package:servicex_client_app/presentation/screens/home/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_screen_card.dart';

class AllFavouritesScreen extends StatelessWidget {
  const AllFavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Favourites'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
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
