import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class DetailsSection extends StatelessWidget {
  final TextEditingController detailsController;
  final List<File> pickedImages;
  final Future<void> Function() onPickImages;
  final Future<void> Function() onPickCameraImage;
  final void Function(int) onRemoveImage;

  const DetailsSection({
    super.key,
    required this.detailsController,
    required this.pickedImages,
    required this.onPickImages,
    required this.onPickCameraImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Details",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),

        // Upload Photos Container
        InkWell(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Camera'),
                      onTap: () {
                        Navigator.pop(ctx);
                        onPickCameraImage();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () {
                        Navigator.pop(ctx);
                        onPickImages();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: XColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Iconsax.gallery, color: XColors.success),
                    SizedBox(width: 10),
                    Text("Upload Photos", style: TextStyle(fontSize: 13)),
                  ],
                ),
                if (pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pickedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 5),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              pickedImages[i],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => onRemoveImage(i),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Details TextField
        TextField(
          controller: detailsController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: "Add Details.....",
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
