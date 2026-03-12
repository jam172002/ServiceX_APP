import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/screens/service_provider_profile/service_provider_profile_screen.dart';
import 'package:servicex_client_app/presentation/widgets/service_provider_ver_card.dart';
import 'package:servicex_client_app/presentation/widgets/simple_heading.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../domain/models/fixxer_model.dart';

class SingleSubCategory extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;
  final List<FixxerUser> providers; // ✅ was List<Map<String, dynamic>>
  final bool isLoading;

  const SingleSubCategory({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
    required this.providers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        XHeading(
          title: title,
          actionText: actionText,
          onActionTap: onActionTap,
          showActionButton: true,
          sidePadding: 16,
        ),
        const SizedBox(height: 15),

        if (isLoading)
          const _ProviderListShimmer()
        else if (providers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No providers available for $title.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        else
          _FixxerHorizontalList(fixxers: providers),
      ],
    );
  }
}

// ── Horizontal list (uses same ServiceProviderVerCard as home) ────

class _FixxerHorizontalList extends StatelessWidget {
  final List<FixxerUser> fixxers;
  const _FixxerHorizontalList({required this.fixxers});

  @override
  Widget build(BuildContext context) {
    final display = fixxers.length > 8 ? fixxers.sublist(0, 8) : fixxers;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SizedBox(
        height: 235,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: display.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, i) {
            final FixxerUser fixxer = display[i];
            return ServiceProviderVerCard(
              name: fixxer.fullName,
              location: fixxer.location.address.isNotEmpty
                  ? fixxer.location.address.split(',').first
                  : 'Location not set',
              rating: fixxer.rating,
              imageUrl: fixxer.profileImageUrl,
              image: XImages.serviceProvider,
              onTap: () => Get.to(
                    () => ServiceProviderProfileScreen(),
                arguments: fixxer,
              ),
              onBook: () => Get.to(
                    () => ServiceProviderProfileScreen(),
                arguments: fixxer,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────

class _ProviderListShimmer extends StatelessWidget {
  const _ProviderListShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}