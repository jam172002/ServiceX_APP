import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class ServiceProviderProfileHeader extends StatelessWidget {
  final bool hasProfileImage;
  final bool hasBanner;
  final String profileImagePath;
  final String bannerImagePath;
  final String name;
  final String location;

  const ServiceProviderProfileHeader({
    super.key,
    this.hasProfileImage = true,
    this.hasBanner = true,
    this.profileImagePath = XImages.serviceProvider,
    this.bannerImagePath = XImages.serviceProviderBanner,
    this.name = 'Muhammad Sufyan',
    this.location = 'Bahawalpur, Pakistan',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(color: XColors.lightTint),
          child: hasBanner && bannerImagePath.isNotEmpty
              ? Image.asset(bannerImagePath, fit: BoxFit.cover)
              : Container(color: XColors.borderColor),
        ),

        // Profile avatar & info (overlapping banner)
        Positioned(
          bottom: -75,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar + Name
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: XColors.primaryBG, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: XColors.lighterTint,
                      child: hasProfileImage
                          ? ClipOval(
                              child: Image.asset(
                                profileImagePath,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 30,
                              color: XColors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Location
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: XColors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: XColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
