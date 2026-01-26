import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class ServiceProviderScreenCard extends StatelessWidget {
  final String category;
  final String name;
  final String rating;
  final String location;
  final String amount;
  final VoidCallback? onTap;

  const ServiceProviderScreenCard({
    super.key,
    required this.category,
    required this.name,
    required this.rating,
    required this.location,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: XColors.lightTint.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              /// Provider Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  XImages.serviceProvider,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              /// Details Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: XColors.lightTint.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: XColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Name
                    Row(
                      children: [
                        const Icon(
                          Iconsax.user,
                          size: 16,
                          color: XColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Rating + Location
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 11,
                                color: XColors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Iconsax.star5,
                              size: 16,
                              color: XColors.warning,
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        Row(
                          children: [
                            const Icon(
                              Iconsax.location5,
                              size: 16,
                              color: XColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: XColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Price
                    Row(
                      children: [
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: XColors.primary,
                          ),
                        ),
                        const Text(
                          ' /hour',
                          style: TextStyle(fontSize: 10, color: XColors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
