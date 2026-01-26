import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/others/full_screen_media_viewer_screen.dart';

class RequestPhotoCard extends StatelessWidget {
  final String mediaPath;
  final double size;
  final bool isVideo;

  const RequestPhotoCard({
    super.key,
    required this.mediaPath,
    this.size = 70,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate using GetX
        Get.to(() => FullScreenMediaViewer(url: mediaPath, isVideo: isVideo));
      },
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black12,
          image: isVideo
              ? null
              : DecorationImage(
                  image: _loadImage(mediaPath),
                  fit: BoxFit.cover,
                ),
        ),
        child: isVideo
            ? const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
              )
            : null,
      ),
    );
  }

  ImageProvider _loadImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.contains("/storage") || path.contains("C:\\")) {
      return FileImage(File(path));
    } else {
      return AssetImage(path);
    }
  }
}
