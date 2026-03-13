import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:servicex_client_app/domain/models/job_request_model.dart';
import 'package:servicex_client_app/domain/models/quote_model.dart';
import 'package:servicex_client_app/presentation/screens/chat/single_chat_screen.dart';
import 'package:servicex_client_app/presentation/screens/chat/controller/chat_controller.dart';
import 'package:servicex_client_app/services/chat_notification_service.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

import 'controller/quotes_list_controller.dart';

class QuotesListScreen extends StatelessWidget {
  final JobRequestModel job;
  const QuotesListScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(QuotesController(job: job), tag: job.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: XColors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quotes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: XColors.black)),
            Text(
              job.subcategoryName.isNotEmpty ? job.subcategoryName : job.categoryName,
              style: const TextStyle(fontSize: 11, color: XColors.grey, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());

        if (c.error.value.isNotEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(c.error.value, textAlign: TextAlign.center,
                  style: const TextStyle(color: XColors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: c.refresh,
                  icon: const Icon(Icons.refresh), label: const Text('Retry')),
            ]),
          );
        }

        if (c.quotes.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Iconsax.document_text,
                  size: 64, color: XColors.grey.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('No quotes yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: XColors.black)),
              const SizedBox(height: 6),
              const Text('Service providers will send quotes\nonce they see your job.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: XColors.grey)),
            ]),
          );
        }

        return RefreshIndicator(
          onRefresh: c.refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: c.quotes.length,
            itemBuilder: (_, i) => _QuoteCard(quote: c.quotes[i], job: job, controller: c),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _QuoteCard extends StatefulWidget {
  final QuoteModel quote;
  final JobRequestModel job;
  final QuotesController controller;
  const _QuoteCard({required this.quote, required this.job, required this.controller});

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  bool _chatLoading = false;

  QuoteModel get q => widget.quote;
  QuotesController get c => widget.controller;

  Color get _statusColor {
    switch (q.status) {
      case QuoteStatus.accepted: return Colors.green;
      case QuoteStatus.rejected: return Colors.red;
      case QuoteStatus.pending:  return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (q.status) {
      case QuoteStatus.accepted: return 'Accepted';
      case QuoteStatus.rejected: return 'Rejected';
      case QuoteStatus.pending:  return 'Pending';
    }
  }

  Future<void> _openChat() async {
    setState(() => _chatLoading = true);
    try {
      if (!Get.isRegistered<ChatController>()) Get.put(ChatController());
      final ctrl    = Get.find<ChatController>();
      final myToken = await ChatNotificationService.instance.getToken();

      await ctrl.openChat(
        otherId:       q.fixxerId,
        otherName:     q.fixxerName.isNotEmpty ? q.fixxerName : 'Service Provider',
        otherAvatar:   q.fixxerAvatar,
        otherFcmToken: q.fixxerFcmToken,
        myFcmToken:    myToken,
      );
      if (!mounted) return;

      Get.to(() => SingleChatScreen(
        conversationId:  ctrl.activeConversationId.value,
        otherUserId:     q.fixxerId,
        otherUserName:   q.fixxerName.isNotEmpty ? q.fixxerName : 'Service Provider',
        otherUserAvatar: q.fixxerAvatar,
        isServiceProvider: false,
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
    } finally {
      if (mounted) setState(() => _chatLoading = false);
    }
  }


  void _showBookConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Book this provider?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        content: Text(
          'You are about to accept the quote from '
              '${q.fixxerName.isNotEmpty ? q.fixxerName : "this provider"} '
              'for \$${q.price}. Other pending quotes will be rejected.',
          style: const TextStyle(fontSize: 13, color: XColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: XColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: XColors.primary),
            onPressed: () {
              Get.back();
              c.acceptQuote(widget.quote);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arrivalFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(q.arrivalAt);
    final canAct = q.status == QuoteStatus.pending && !c.hasAccepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: XColors.lightTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: q.status == QuoteStatus.accepted
            ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1.5)
            : q.status == QuoteStatus.rejected
            ? Border.all(color: Colors.red.withValues(alpha: 0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Provider row ───────────────────────────────────────────────
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: XColors.grey.withValues(alpha: 0.2),
              backgroundImage: q.fixxerAvatar.isNotEmpty
                  ? NetworkImage(q.fixxerAvatar) as ImageProvider : null,
              child: q.fixxerAvatar.isEmpty
                  ? const Icon(Iconsax.user, size: 22, color: XColors.grey) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  q.fixxerName.isNotEmpty ? q.fixxerName : 'Service Provider',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: XColors.black),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(q.createdAt),
                  style: const TextStyle(fontSize: 11, color: XColors.grey),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_statusLabel,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor)),
            ),
          ]),

          const SizedBox(height: 12),
          Divider(color: XColors.borderColor.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 12),

          // ── Quote details ──────────────────────────────────────────────
          Row(children: [
            _Detail(
              icon: Iconsax.money,
              label: 'Quoted Price',
              value: '\$${q.price}',
              valueColor: Colors.green,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _Detail(
                icon: Iconsax.clock,
                label: 'Arrival',
                value: arrivalFormatted,
              ),
            ),
          ]),

          if (q.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: XColors.borderColor.withValues(alpha: 0.4)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Iconsax.message_text_1, size: 14, color: XColors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(q.note,
                      style: const TextStyle(fontSize: 12, color: XColors.grey)),
                ),
              ]),
            ),
          ],

          // ── Actions ────────────────────────────────────────────────────
          if (q.status != QuoteStatus.rejected) ...[
            const SizedBox(height: 14),
            Obx(() {
              final isAccepting = c.acceptingId.value == q.fixxerId;
              return Row(children: [
                // Chat button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _chatLoading ? null : _openChat,
                    icon: _chatLoading
                        ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: XColors.primary))
                        : const Icon(Iconsax.sms, size: 16, color: XColors.primary),
                    label: const Text('Chat',
                        style: TextStyle(color: XColors.primary, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: XColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                if (canAct) ...[
                  const SizedBox(width: 10),
                  // Book button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAccepting ? null : () => _showBookConfirm(context),
                      icon: isAccepting
                          ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Icon(Iconsax.tick_circle, size: 16, color: Colors.white),
                      label: const Text('Book',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: XColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ]);
            }),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Detail(
      {required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12, color: XColors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: XColors.grey)),
      ]),
      const SizedBox(height: 2),
      Text(value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? XColors.black)),
    ]);
  }
}