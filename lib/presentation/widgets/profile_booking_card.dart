import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/request_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../services/chat_notification_service.dart';
import '../screens/chat/controller/chat_controller.dart';
import '../screens/chat/single_chat_screen.dart';

class ProfileBookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProfileBookingCard({super.key, required this.data});

  // ── Status colour ──────────────────────────────────────────────

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'rebooked':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── Open chat ──────────────────────────────────────────────────

  Future<void> _openChat() async {
    final spId = data['spId'] as String? ?? '';
    final spName = data['spName'] as String? ?? 'Service Provider';
    final spAvatar = data['spAvatar'] as String? ?? '';
    final spFcmToken = data['spFcmToken'] as String?;

    if (spId.isEmpty) {
      Get.snackbar('Error', 'Provider info not available');
      return;
    }

    try {
      final ctrl = Get.find<ChatController>();
      final myToken = await ChatNotificationService.instance.getToken();

      await ctrl.openChat(
        otherId: spId,
        otherName: spName,
        otherAvatar: spAvatar,
        otherFcmToken: spFcmToken,
        myFcmToken: myToken,
      );

      Get.to(() => SingleChatScreen(
        conversationId: ctrl.activeConversationId.value,
        otherUserId: spId,
        otherUserName: spName,
        otherUserAvatar: spAvatar,
        isServiceProvider: false,
      ));
    } catch (_) {
      Get.snackbar('Error', 'Could not open chat. Please try again.');
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? '';

    return GestureDetector(
      onTap: () => Get.to(() => RequestDetailScreen(
        isRequestDetailScreen: false,
        jobId: data['jobId'] as String? ?? '',
      )),
      child: Container(
        width: 240,
        height: 120,
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
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
            // Left accent strip
            Container(
              width: 5,
              height: double.infinity,
              decoration: BoxDecoration(
                color: statusColor(status),
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
                    // Avatar + name + chat icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage:
                          AssetImage(XImages.serviceProvider02),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data['spName'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openChat,
                          child: const Icon(
                            Iconsax.sms,
                            size: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Type + status pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['spType'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 10, color: XColors.grey),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor(status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.capitalizeFirst!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      data['desc'] as String? ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9, color: XColors.grey),
                    ),
                    const Spacer(),

                    // Price + time + distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                            XColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\$${data["price"]}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: XColors.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Iconsax.clock,
                                size: 10, color: XColors.primary),
                            const SizedBox(width: 2),
                            Text(
                              data['time'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 9, color: XColors.grey),
                            ),
                            const SizedBox(width: 6),
                            Icon(Iconsax.location,
                                size: 10, color: XColors.primary),
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 40,
                              child: Text(
                                data['distance'] as String? ?? '– km',
                                style: const TextStyle(
                                    fontSize: 9, color: XColors.grey),
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