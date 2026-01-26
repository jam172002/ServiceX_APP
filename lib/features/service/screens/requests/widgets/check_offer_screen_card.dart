import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/dialogs/reject_offer_dialog.dart';
import 'package:servicex_client_app/common/widgets/others/expandable_text.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/service_provider_profile_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class CheckOfferScreenCard extends StatelessWidget {
  final String name;
  final String profession;
  final String timeAgo;
  final String distance;
  final double rating;
  final String price;
  final String estimatedTime;
  final String dateTime;
  final String description;

  const CheckOfferScreenCard({
    super.key,
    required this.name,
    required this.profession,
    required this.timeAgo,
    required this.distance,
    required this.rating,
    required this.price,
    required this.estimatedTime,
    required this.dateTime,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: XColors.lighterTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //? Service Provider Row
          GestureDetector(
            onTap: () {
              Get.to(() => ServiceProviderProfileScreen());
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(XImages.serviceProvider),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: XColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Iconsax.briefcase,
                              color: XColors.primary,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              profession,
                              style: const TextStyle(
                                color: XColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.clock,
                              color: XColors.primary,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: XColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              color: XColors.primary,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              distance,
                              style: const TextStyle(
                                color: XColors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(EdgeInsets.zero),
                            minimumSize: WidgetStateProperty.all(Size.zero),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          icon: Icon(
                            Iconsax.sms,
                            size: 15,
                            color: Colors.green,
                          ),
                          label: Text(
                            'Chat',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: XColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Icon(
                          Iconsax.star5,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: XColors.borderColor, height: 0.2),
          const SizedBox(height: 12),

          ExpandableText(
            text: description,
            textColor: XColors.grey,
            textSize: 13,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          //? Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Offered',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: XColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          //? Date & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date & Time',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                dateTime,
                style: const TextStyle(
                  color: XColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          //? Estimated Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Time',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                estimatedTime,
                style: const TextStyle(
                  color: XColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //? Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.dialog(
                    RejectDialog(
                      title: 'Reject Offer',
                      subtitle:
                          'Please provide a reason for rejecting this offer.',
                      hintText: 'Write your reason...',
                      onSubmit: (String p1) {},
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: XColors.danger.withValues(alpha: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: XColors.danger),
                  ),
                  child: const Text(
                    "Reject",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
