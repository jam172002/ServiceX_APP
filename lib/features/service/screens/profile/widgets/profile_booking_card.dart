import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/inbox/linked_screens/single_chat_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/request_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class ProfileBookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProfileBookingCard({super.key, required this.data});

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "booked":
      case "rebooked":
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "inprogress":
        return Colors.purple;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => RequestDetailScreen(isRequestDetailScreen: false)),
      child: Container(
        width: 240,
        height: 120,
        padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              XColors.lightTint.withValues(alpha: 0.25),
              XColors.lightTint.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Accent Strip for status
            Container(
              width: 5,
              height: double.infinity,
              decoration: BoxDecoration(
                color: statusColor(data["status"]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Avatar + Name + Chat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage(
                            XImages.serviceProvider02,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data["spName"],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(
                            () => SingleChatScreen(isServiceProvider: false),
                          ),
                          child: const Icon(
                            Iconsax.sms,
                            size: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Middle Row: Type + Status pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data["spType"],
                          style: const TextStyle(
                            fontSize: 10,
                            color: XColors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(
                              data["status"],
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
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
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      data["desc"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: XColors.grey),
                    ),
                    const Spacer(),

                    // Bottom Row: Price + Time + Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: XColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "\$${data["price"]}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: XColors.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 10,
                              color: XColors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              data["time"],
                              style: const TextStyle(
                                fontSize: 9,
                                color: XColors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Iconsax.location,
                              size: 10,
                              color: XColors.primary,
                            ),
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 40,
                              child: Text(
                                data["distance"] ?? "– km",
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: XColors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
