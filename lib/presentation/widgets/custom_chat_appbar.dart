import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class CustomChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String location;
  final String country;
  final String? imagePath;

  /// Set to [true] when [imagePath] is an https:// URL (Firebase Storage / CDN).
  /// Defaults to [false] (asset path behaviour, same as before).
  final bool isNetworkImage;

  final VoidCallback onMoreTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onProfileTap;

  const CustomChatAppBar({
    super.key,
    required this.name,
    required this.location,
    required this.country,
    this.imagePath,
    this.isNetworkImage = false,
    required this.onMoreTap,
    this.onLocationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  bool get _hasImage => imagePath != null && imagePath!.trim().isNotEmpty;

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
            // ── Profile image ──────────────────────────────────────
            GestureDetector(
              onTap: onProfileTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _hasImage
                    ? (isNetworkImage
                    ? _networkImage()
                    : _assetImage())
                    : _defaultProfileBox(),
              ),
            ),

            const SizedBox(width: 12),

            // ── Name + location ────────────────────────────────────
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
                  // Only show location row when there is content
                  if (location.isNotEmpty || country.isNotEmpty)
                    GestureDetector(
                      onTap: onLocationTap,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.location5,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              [location, country]
                                  .where((s) => s.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── More / ellipsis ────────────────────────────────────
            GestureDetector(
              onTap: onMoreTap,
              child: const Icon(
                LucideIcons.ellipsis_vertical,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image variants ─────────────────────────────────────────────

  Widget _assetImage() => Image.asset(
    imagePath!,
    height: 50,
    width: 50,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => _defaultProfileBox(),
  );

  Widget _networkImage() => CachedNetworkImage(
    imageUrl: imagePath!,
    height: 50,
    width: 50,
    fit: BoxFit.cover,
    placeholder: (_, __) => _shimmerBox(),
    errorWidget: (_, __, ___) => _defaultProfileBox(),
  );

  Widget _shimmerBox() => Container(
    height: 50,
    width: 50,
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(12),
    ),
  );

  Widget _defaultProfileBox() => Container(
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