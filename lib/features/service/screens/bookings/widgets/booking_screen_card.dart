import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/inbox/linked_screens/single_chat_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/request_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

class BookingScreenCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const BookingScreenCard({super.key, required this.data});

  Color statusColor(String status) {
    switch (status) {
      case "booked":
      case "rebooked":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "inprogress":
        return Colors.purple;
      case "completed":
        return Colors.teal;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = XHelperFunctions.screenWidth();

    return GestureDetector(
      onTap: () =>
          Get.to(() => RequestDetailScreen(isRequestDetailScreen: false)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: XColors.lighterTint.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 SP Row
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(XImages.serviceProvider02),
                ),
                const SizedBox(width: 10),

                /// 🔥 Texts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name + Chat
                    Row(
                      children: [
                        Text(
                          data["spName"],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: XColors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Get.to(
                            () => SingleChatScreen(isServiceProvider: false),
                          ),
                          child: const Icon(
                            Iconsax.sms,
                            size: 15,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Type - Time - Distance
                    Row(
                      children: [
                        Icon(
                          Iconsax.briefcase,
                          size: 11,
                          color: XColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data["spType"],
                          style: const TextStyle(
                            fontSize: 10,
                            color: XColors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Icon(Iconsax.clock, size: 11, color: XColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          data["time"],
                          style: const TextStyle(
                            fontSize: 10,
                            color: XColors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Icon(
                          Iconsax.location,
                          size: 11,
                          color: XColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data["distance"] ??
                              "– km away", // fallback if distance not provided
                          style: const TextStyle(
                            fontSize: 10,
                            color: XColors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 🔥 STATUS TAG
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor(
                          data["status"],
                        ).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data["status"].toString().capitalizeFirst!,

                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor(data["status"]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(
              color: XColors.borderColor.withValues(alpha: 0.4),
              height: 0.2,
            ),
            const SizedBox(height: 12),

            /// Description
            Text(
              data["desc"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: XColors.grey),
            ),

            const SizedBox(height: 12),

            /// Price
            _row("Price", "\$${data["price"]}"),

            /// Estimated Time
            _row("Estimated Time", "3 Hours"),

            /// Payment
            _row("Payment Method", "MasterCard"),

            /// Location
            _row("Location", data["location"], maxWidth: width * 0.45),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value, {double? maxWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),

        SizedBox(
          width: maxWidth ?? 120,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: XColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
