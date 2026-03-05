import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String location;
  final String country;
  final String? imagePath; // asset path OR network URL

  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  const CustomHomeAppBar({
    super.key,
    required this.name,
    required this.location,
    required this.country,
    this.imagePath,
    this.onNotificationTap,
    this.onSettingTap,
    this.onLocationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  bool get _isNetworkImage {
    if (imagePath == null) return false;
    return imagePath!.startsWith('http://') ||
        imagePath!.startsWith('https://');
  }

  bool get _isAssetImage {
    if (imagePath == null) return false;
    if (imagePath!.trim().isEmpty) return false;
    return !_isNetworkImage;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: XColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ── PROFILE IMAGE ──────────────────────────────────────────
            GestureDetector(
              onTap: onProfileTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildProfileImage(),
              ),
            ),

            const SizedBox(width: 12),

            // ── NAME + LOCATION ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.location5,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$location, $country',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── ICONS ──────────────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onNotificationTap,
                  child: const Icon(
                    Iconsax.notification5,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: onSettingTap,
                  child: const Icon(
                    Iconsax.setting_2,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isNetworkImage) {
      return Image.network(
        imagePath!,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultProfileBox(),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _defaultProfileBox();
        },
      );
    }

    if (_isAssetImage) {
      return Image.asset(
        imagePath!,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultProfileBox(),
      );
    }

    return _defaultProfileBox();
  }

  Widget _defaultProfileBox() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: XColors.primaryBG.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(Iconsax.user, color: Colors.black54, size: 26),
    );
  }
}