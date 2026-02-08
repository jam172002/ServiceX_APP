import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/common/widgets/dialogs/reject_offer_dialog.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/create_service_job_screen.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/service_provider_profile_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/linked_screens/check_offers_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/request_details_screen_photos_list.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class RequestDetailScreen extends StatelessWidget {
  final bool isRequestDetailScreen;

  const RequestDetailScreen({super.key, required this.isRequestDetailScreen});

  @override
  Widget build(BuildContext context) {
    // change this value to test different statuses
    final String status =
        "cancelled_by_sp"; // e.g. new, under_review, accepted, booked, rebooked, pending, inprogress, completed, cancelled_by_me, cancelled_by_sp

    Widget logicalDivider() => Column(
      children: [
        SizedBox(height: 6),
        Divider(color: XColors.borderColor.withValues(alpha: 0.3), height: 0.2),
        SizedBox(height: 6),
      ],
    );

    // UI status text mapping (shows specific status names in UI)
    String getStatusText(String status) {
      switch (status) {
        case "new":
          return "New";
        case "under_review":
          return "Under Review";
        case "accepted":
          return "Accepted";
        case "booked":
          return "Booked";
        case "rebooked":
          return "Rebooked";
        case "pending":
          return "Pending";
        case "inprogress":
          return "In Progress";
        case "completed":
          return "Completed";
        case "cancelled_by_me":
        case "cancelled_by_sp":
          return "Cancelled";
        default:
          return "";
      }
    }

    // Status color mapping
    Color getStatusColor(String status) {
      switch (status) {
        case "new":
          return Colors.blue;
        case "under_review":
          return Colors.orange;
        case "accepted":
        case "booked":
        case "rebooked":
          return Colors.green;
        case "pending":
          return Colors.orange;
        case "inprogress":
          return Colors.purple;
        case "completed":
          return Colors.teal;
        case "cancelled_by_me":
        case "cancelled_by_sp":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // Backend mapping: map accepted/booked/rebooked -> "confirmed"
    String getBackendStatus(String status) {
      if (["accepted", "booked", "rebooked"].contains(status)) {
        return "confirmed";
      }
      return status;
    }

    // Helper checks
    bool isConfirmed() => ["accepted", "booked", "rebooked"].contains(status);

    bool showCancelButton() => [
      "pending",
      "new",
      "under_review",
      "inprogress",
      "accepted",
      "booked",
      "rebooked",
    ].contains(status);

    return Scaffold(
      appBar: XAppBar(
        title: isRequestDetailScreen ? 'Request Details' : 'Booking Details',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Sub Category image
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(XImages.serviceProviderBanner),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Main Title & Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wiring & Rewiring',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Electrical',
                    style: TextStyle(
                      color: XColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Description:',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: XColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // Service Provider Section (visible for confirmed/inprogress/completed/cancelled_by_sp)
              if (isConfirmed() ||
                  [
                    "inprogress",
                    "completed",
                    "cancelled_by_sp",
                  ].contains(status))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Provider',
                      style: TextStyle(
                        color: XColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(XImages.serviceProvider),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Muhammad Sufyan',
                              style: TextStyle(
                                color: XColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Electrician',
                              style: TextStyle(
                                color: XColors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton.filled(
                          onPressed: () {
                            Get.to(() => ServiceProviderProfileScreen());
                          },
                          icon: Icon(
                            Iconsax.user,
                            color: XColors.primary,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: XColors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () {},
                          icon: Icon(
                            Iconsax.sms,
                            color: XColors.primary,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: XColors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(
                      color: XColors.borderColor.withValues(alpha: 0.3),
                      height: 0.2,
                    ),
                    SizedBox(height: 12),
                  ],
                ),

              // STATUS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: XColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      getStatusText(status),
                      style: TextStyle(
                        fontSize: 11,
                        color: getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // Cancelled Section (only shows when cancelled)
              if (["cancelled_by_me", "cancelled_by_sp"].contains(status))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cancelled By:',
                          style: TextStyle(
                            color: XColors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          status == "cancelled_by_me"
                              ? "You"
                              : "Service Provider",
                          style: TextStyle(
                            color: XColors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Reason for cancellation is natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: XColors.danger.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 12),
                    Divider(
                      color: XColors.borderColor.withValues(alpha: 0.3),
                      height: 0.2,
                    ),
                    SizedBox(height: 12),
                  ],
                ),

              // Payment Method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      color: XColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Master Card',
                    style: TextStyle(
                      color: XColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(Iconsax.location, color: XColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Model Town, Bahawalpur',
                    style: TextStyle(
                      color: XColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(Iconsax.calendar_1, color: XColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'November 27, 2025 / 11:00 AM',
                    style: TextStyle(
                      color: XColors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Estimated Time (shows only when confirmed/inprogress/completed)
              if (isConfirmed() || ["inprogress", "completed"].contains(status))
                Row(
                  children: [
                    Icon(Iconsax.clock, color: XColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Estimated Time 3 hours',
                      style: TextStyle(
                        color: XColors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // Photos
              Text(
                'Photos',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              RequestPhotoList(),

              SizedBox(height: 12),
              Divider(
                color: XColors.borderColor.withValues(alpha: 0.3),
                height: 0.2,
              ),
              SizedBox(height: 12),

              // PRICE DETAILS — original logic preserved
              Text(
                'Price Details',
                style: TextStyle(
                  color: XColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: XColors.lightTint.withValues(alpha: 0.5),
                ),
                child: Column(
                  children: [
                    // BUDGET (for new, under_review, cancelled_by_me)
                    if ([
                      "new",
                      "under_review",
                      "cancelled_by_me",
                    ].contains(status))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget',
                            style: TextStyle(
                              color: XColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$50 - \$150',
                            style: TextStyle(
                              color: XColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    // PRICE (for confirmed, inprogress, completed, cancelled_by_sp)
                    if (isConfirmed() ||
                        status == "inprogress" ||
                        status == "completed" ||
                        status == "cancelled_by_sp") ...[
                      if (![
                        "new",
                        "under_review",
                        "cancelled_by_me",
                        "completed",
                        "pending",
                      ].contains(status))
                        logicalDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price',
                            style: TextStyle(
                              color: XColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$90',
                            style: TextStyle(
                              color: XColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // COMMISSION (inprogress, completed, cancelled_by_sp)
                    if ([
                      "inprogress",
                      "completed",
                      "cancelled_by_sp",
                    ].contains(status)) ...[
                      logicalDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commission (10%)',
                            style: TextStyle(
                              color: XColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$20',
                            style: TextStyle(
                              color: XColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // TOTAL (completed only)
                    if (status == "completed") ...[
                      logicalDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: XColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$110',
                            style: TextStyle(
                              color: XColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 40),

              // CANCEL BUTTON -> shown for pending, new, under_review, inprogress, and confirmed group
              if (showCancelButton())
                OutlinedButton.icon(
                  onPressed: () => Get.dialog(
                    RejectDialog(
                      title: 'Cancel Request',
                      subtitle:
                          'Please provide a reason for cancellation of this request.',
                      hintText: 'Write your reason...',
                      onSubmit: (String p1) {},
                    ),
                  ),
                  icon: Icon(Icons.clear, color: XColors.danger),
                  label: const Text(
                    'Cancel Request',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                      color: XColors.danger,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(45),
                    side: const BorderSide(color: XColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              SizedBox(height: 10),

              // ACTION BUTTON LOGIC
              // Hide all action buttons when status == "pending"
              if (status != "pending") ...[
                if (status == "new")
                  ActionBtn(
                    text: "Check Offers",
                    onTap: () => Get.to(() => CheckOfferScreen()),
                  )
                else if (status == "completed" || status == "cancelled_by_sp")
                  ActionBtn(
                    text: "Rebook",
                    onTap: () => Get.to(
                      () =>
                          CreateServiceJobScreen(showServiceProviderCard: true),
                    ),
                  )
                else if (status == "inprogress" || isConfirmed())
                  ActionBtn(text: "Mark as Finished", onTap: () {}),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 🔥 REUSABLE ACTION BUTTON
class ActionBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ActionBtn({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: XColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }
}
