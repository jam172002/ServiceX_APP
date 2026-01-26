import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_cancel_job_dialog.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_job_actionbar.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/fixxers/fixxer_quote_dialog.dart';
import 'package:servicex_client_app/features/service/screens/inbox/linked_screens/single_chat_screen.dart';
import 'package:servicex_client_app/features/service/screens/requests/widgets/request_details_screen_photos_list.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

/// =======================
/// JOB STATUS ENUM
/// =======================
enum FixxerJobStatus {
  newRequest,
  quoteSent,
  quoteAccepted,
  quoteCancelled,
  jobStarted,
  jobCancelled,
  completed,
}

class FixxerJobDetailScreen extends StatefulWidget {
  const FixxerJobDetailScreen({super.key});

  @override
  State<FixxerJobDetailScreen> createState() => _FixxerJobDetailScreenState();
}

class _FixxerJobDetailScreenState extends State<FixxerJobDetailScreen> {
  FixxerJobStatus jobStatus = FixxerJobStatus.quoteAccepted;

  String? quotedPrice;
  DateTime? quotedDeadline;
  String? cancelReason;
  String? jobCancelReason;
  String? cancelBy; // "Me" or "Client"
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: FixxerJobActionBar(
        status: jobStatus,
        onPrimaryAction: _handlePrimaryAction,
        onSecondaryAction: _handleSecondaryAction,
      ),
    );
  }

  /// =======================
  /// APP BAR
  /// =======================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
      title: const Text(
        'Plumbing',
        style: TextStyle(
          color: XColors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Iconsax.heart5 : Iconsax.heart,
            color: isFavorite ? XColors.danger : XColors.grey,
            size: 20,
          ),
          onPressed: () {
            setState(() => isFavorite = !isFavorite);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// =======================
  /// BODY
  /// =======================
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Client Info
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/service-provider.jpg',
                ),
                radius: 30,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Client',
                    style: TextStyle(color: XColors.primary, fontSize: 11),
                  ),
                  Text(
                    'Muhammad Sufyan',
                    style: TextStyle(
                      color: XColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.to(() => SingleChatScreen(isServiceProvider: true));
                },
                child: const Icon(
                  Iconsax.sms,
                  size: 22,
                  color: XColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: XColors.borderColor.withValues(alpha: 0.3)),
          const SizedBox(height: 12),

          _infoRow('Job', 'Leakage Fix'),
          _infoRow('Budget', '\$30 - \$50'),
          _infoRow('Location', 'Model Town Bahawalpur'),
          _infoRow('Date & Time', '25 Jan 2026, 12:00 PM'),
          _infoRow('Payment', 'Master Card'),

          const SizedBox(height: 12),
          Divider(color: XColors.borderColor.withValues(alpha: 0.3)),
          const SizedBox(height: 12),

          const Text(
            'Description',
            style: TextStyle(
              color: XColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sed ut perspiciatis unde omnis iste natus error sit voluptatem.',
            style: TextStyle(color: XColors.grey, fontSize: 12),
          ),

          const SizedBox(height: 12),
          Divider(color: XColors.borderColor.withValues(alpha: 0.3)),
          const SizedBox(height: 12),

          const Text(
            'Photos',
            style: TextStyle(
              color: XColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const RequestPhotoList(),

          /// QUOTE / JOB INFO CONTAINER
          if (jobStatus != FixxerJobStatus.newRequest) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    (jobStatus == FixxerJobStatus.quoteCancelled ||
                        jobStatus == FixxerJobStatus.jobCancelled)
                    ? XColors.danger.withValues(alpha: 0.08)
                    : XColors.lightTint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border:
                    (jobStatus == FixxerJobStatus.quoteCancelled ||
                        jobStatus == FixxerJobStatus.jobCancelled)
                    ? Border.all(color: XColors.danger.withValues(alpha: 0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Show price and booking date for quoteSent, quoteAccepted, jobStarted, completed
                  if (jobStatus != FixxerJobStatus.quoteCancelled &&
                      jobStatus != FixxerJobStatus.jobCancelled) ...[
                    _infoRow('Price Offered', '\$${quotedPrice ?? ''}'),
                    _infoRow(
                      'Booking Date',
                      quotedDeadline == null
                          ? ''
                          : '${quotedDeadline!.day}/${quotedDeadline!.month}/${quotedDeadline!.year}',
                    ),
                  ],

                  /// Status
                  _infoRow('Status', switch (jobStatus) {
                    FixxerJobStatus.quoteSent => 'Quote Sent',
                    FixxerJobStatus.quoteAccepted => 'Quote Accepted',
                    FixxerJobStatus.jobStarted => 'Job Started',
                    FixxerJobStatus.completed => 'Completed',
                    FixxerJobStatus.quoteCancelled =>
                      'Cancelled by ${cancelBy ?? "Me"}',
                    FixxerJobStatus.jobCancelled =>
                      'Cancelled by ${cancelBy ?? "Me"}',
                    _ => 'Pending',
                  }),

                  /// Cancel Reason for quoteCancelled
                  if (jobStatus == FixxerJobStatus.quoteCancelled &&
                      cancelReason != null) ...[
                    const SizedBox(height: 8),
                    Divider(color: XColors.borderColor.withValues(alpha: 0.3)),
                    const SizedBox(height: 6),
                    const Text(
                      'Cancel Reason',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: XColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cancelReason!,
                      style: const TextStyle(fontSize: 12, color: XColors.grey),
                    ),
                  ],

                  /// Cancel Reason for jobCancelled
                  if (jobStatus == FixxerJobStatus.jobCancelled &&
                      jobCancelReason != null) ...[
                    const SizedBox(height: 8),
                    Divider(color: XColors.borderColor.withValues(alpha: 0.3)),
                    const SizedBox(height: 6),
                    const Text(
                      'Job Cancel Reason',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: XColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jobCancelReason!,
                      style: const TextStyle(fontSize: 12, color: XColors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: XColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: XColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// ACTION HANDLERS
  /// =======================
  void _handlePrimaryAction() {
    switch (jobStatus) {
      case FixxerJobStatus.newRequest:
      case FixxerJobStatus.quoteSent:
      case FixxerJobStatus.quoteCancelled:
        showQuoteDialog(
          context,
          isEdit: jobStatus == FixxerJobStatus.quoteSent,
          initialPrice: quotedPrice,
          initialDeadline: quotedDeadline,
          onSubmit: (price, deadline) {
            setState(() {
              quotedPrice = price;
              quotedDeadline = deadline;
              cancelReason = null;
              jobCancelReason = null;
              cancelBy = null;
              jobStatus = FixxerJobStatus.quoteSent;
            });
          },
        );
        break;
      case FixxerJobStatus.quoteAccepted:
        setState(() => jobStatus = FixxerJobStatus.jobStarted);
        break;
      case FixxerJobStatus.jobStarted:
        setState(() => jobStatus = FixxerJobStatus.completed);
        break;
      default:
        break;
    }
  }

  void _handleSecondaryAction() {
    switch (jobStatus) {
      case FixxerJobStatus.quoteSent:
        fixxerShowCancelRequestDialog(
          context,
          onConfirm: (reason) {
            setState(() {
              cancelReason = reason;
              cancelBy = "Me";
              jobStatus = FixxerJobStatus.quoteCancelled;
            });
          },
        );
        break;
      case FixxerJobStatus.quoteAccepted:
      case FixxerJobStatus.jobStarted:
        fixxerShowCancelRequestDialog(
          context,
          onConfirm: (reason) {
            setState(() {
              jobCancelReason = reason;
              cancelBy = "Me"; // or "Client"
              jobStatus = FixxerJobStatus.jobCancelled;
            });
          },
        );
        break;
      default:
        break;
    }
  }
}
