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
  final String? avatarUrl;
  final String? bannerUrl;

  const ServiceProviderProfileHeader({
    super.key,
    this.hasProfileImage = true,
    this.hasBanner = true,
    this.profileImagePath = XImages.serviceProvider,
    this.bannerImagePath = XImages.serviceProviderBanner,
    this.name = 'Muhammad Sufyan',
    this.location = 'Bahawalpur, Pakistan',
    this.avatarUrl,
    this.bannerUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Banner ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(color: XColors.lightTint),
          child: _buildBanner(),
        ),

        // ── Avatar + name + location ──────────────────────────────
        Positioned(
          bottom: -75,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: avatar + name — fixed width so location has room
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: XColors.primaryBG, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: XColors.lighterTint,
                      child: _buildAvatar(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 140,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),

              // Right: location — Flexible so it never overflows
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.location_on,
                          color: XColors.grey, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: XColors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    if (bannerUrl != null && bannerUrl!.isNotEmpty) {
      return Image.network(
        bannerUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetBanner(),
      );
    }
    return _assetBanner();
  }

  Widget _assetBanner() {
    if (hasBanner && bannerImagePath.isNotEmpty) {
      return Image.asset(bannerImagePath, fit: BoxFit.cover);
    }
    return Container(color: XColors.borderColor);
  }

  Widget _buildAvatar() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _assetAvatar(),
        ),
      );
    }
    return _assetAvatar();
  }

  Widget _assetAvatar() {
    if (hasProfileImage && profileImagePath.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          profileImagePath,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(Icons.person, size: 30, color: XColors.grey);
  }
}