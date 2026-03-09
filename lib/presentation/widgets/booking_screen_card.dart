import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/screens/service_requests/request_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';
import 'package:servicex_client_app/utils/helpers/helper_functions.dart';

import '../../services/chat_notification_service.dart';
import '../screens/chat/controller/chat_controller.dart';
import '../screens/chat/single_chat_screen.dart';

class BookingScreenCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const BookingScreenCard({super.key, required this.data});

  // ── Status colour ──────────────────────────────────────────────

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'rebooked':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ── Open chat ──────────────────────────────────────────────────

  Future<void> _openChat() async {
    // Pull SP identifiers from the booking data map.
    // Keys: 'spId', 'spName', 'spAvatar', 'spFcmToken' — add these
    // when you populate the booking data (e.g. from Firestore).
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
    final width = XHelperFunctions.screenWidth();

    return GestureDetector(
      onTap: () => Get.to(() => RequestDetailScreen(
        isRequestDetailScreen: false,
        jobId: data['jobId'] as String? ?? '',
      )),
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
            // ── SP row ─────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(XImages.serviceProvider02),
                ),
                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + chat icon
                    Row(
                      children: [
                        Text(
                          data['spName'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: XColors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _openChat,
                          child: const Icon(
                            Iconsax.sms,
                            size: 15,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Type · time · distance
                    Row(
                      children: [
                        Icon(Iconsax.briefcase,
                            size: 11, color: XColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          data['spType'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 10, color: XColors.grey),
                        ),
                        const SizedBox(width: 8),
                        Icon(Iconsax.clock, size: 11, color: XColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          data['time'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 10, color: XColors.grey),
                        ),
                        const SizedBox(width: 8),
                        Icon(Iconsax.location,
                            size: 11, color: XColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          data['distance'] as String? ?? '– km away',
                          style: const TextStyle(
                              fontSize: 10, color: XColors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Status tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor(data['status'] as String? ?? '')
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (data['status'] as String? ?? '').capitalizeFirst!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                          statusColor(data['status'] as String? ?? ''),
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
                height: 0.2),
            const SizedBox(height: 12),

            // Description
            Text(
              data['desc'] as String? ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: XColors.grey),
            ),

            const SizedBox(height: 12),

            _row('Price', '\$${data["price"]}'),
            _row('Estimated Time', '3 Hours'),
            _row('Payment Method', 'MasterCard'),
            _row('Location', data['location'] as String? ?? '',
                maxWidth: width * 0.45),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value, {double? maxWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
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