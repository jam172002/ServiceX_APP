import 'package:flutter/material.dart';
import 'package:servicex_client_app/common/widgets/cards/service_provider_ver_card.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class ServiceProviderHorizontalList extends StatelessWidget {
  final List<Map<String, dynamic>> providers;
  final double height;

  const ServiceProviderHorizontalList({
    super.key,
    required this.providers,
    this.height = 235,
  });

  @override
  Widget build(BuildContext context) {
    final displayProviders = providers.length > 8
        ? providers.sublist(0, 8)
        : providers;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: displayProviders.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, index) {
            final provider = displayProviders[index];

            return ServiceProviderVerCard(
              name: provider['name'] ?? "Unknown",
              location: provider['location'] ?? "",
              rating: provider['rating'] ?? 0.0,
              image: provider['image'] ?? XImages.serviceProvider,

              // Dynamic tap handlers
              onTap:
                  provider['onTap'] ??
                  () => print("Tapped: ${provider['name']}"),

              onBook:
                  provider['onBook'] ??
                  () => print("Invited: ${provider['name']}"),
            );
          },
        ),
      ),
    );
  }
}
