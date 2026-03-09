import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class AllChatScreenCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String date;
  final String time;
  final int unreadCount;

  /// Either an asset path (default) or an https:// URL.
  /// When null or empty the widget falls back to a default icon.
  final String? avatarUrl;

  final VoidCallback onTap;

  const AllChatScreenCard({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.date,
    required this.time,
    required this.unreadCount,
    this.avatarUrl,
    required this.onTap,
  });

  bool get _isNetwork =>
      avatarUrl != null && avatarUrl!.startsWith('http');

  bool get _isAsset =>
      avatarUrl != null &&
          avatarUrl!.isNotEmpty &&
          !avatarUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Row(
          children: [
            // ── Avatar ─────────────────────────────────────────────
            _buildAvatar(),
            const SizedBox(width: 10),

            // ── Name + last message ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: XColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // ── Time / date / unread badge ─────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: XColors.success,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: XColors.secondaryBG,
                        ),
                      ),
                    ),
                  ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: XColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 8,
                      color: XColors.grey,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                const SizedBox(height: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar builders ────────────────────────────────────────────

  Widget _buildAvatar() {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        imageBuilder: (_, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          radius: 35,
        ),
        placeholder: (_, __) => _shimmerAvatar(),
        errorWidget: (_, __, ___) => _defaultAvatar(),
      );
    }

    if (_isAsset) {
      return CircleAvatar(
        backgroundImage: AssetImage(avatarUrl!),
        radius: 35,
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // Fallback — no URL provided
    return _defaultAvatar();
  }

  Widget _defaultAvatar() => CircleAvatar(
    radius: 35,
    backgroundColor: XColors.lightTint,
    child: const Icon(Iconsax.user, color: XColors.primary, size: 28),
  );

  Widget _shimmerAvatar() => CircleAvatar(
    radius: 35,
    backgroundColor: XColors.lightTint,
  );
}