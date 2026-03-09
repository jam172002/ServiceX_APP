import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/presentation/widgets/custom_chat_appbar.dart';
import 'package:servicex_client_app/presentation/widgets/full_screen_media_viewer_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import '../../../domain/models/message_model.dart';
import 'controller/chat_controller.dart';

class SingleChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool isServiceProvider;

  const SingleChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.isServiceProvider,
  });

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  late final ChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ChatController.to;
    // Mark as read when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.markCurrentChatRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomChatAppBar(
        name: widget.otherUserName,
        location: '',        // Could come from the fixer model if passed
        country: '',
        imagePath: widget.otherUserAvatar,
        isNetworkImage: widget.otherUserAvatar.startsWith('http'),
        onMoreTap: _showMoreOptions,
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────────────
          Expanded(
            child: Obx(() {
              final msgs = _ctrl.messages;

              if (msgs.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet.\nSay hello! 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                );
              }

              return ListView.builder(
                controller: _ctrl.scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final msg = msgs[i];
                  final isUser = msg.senderId == _ctrl.myId;
                  final showDate = _shouldShowDateDivider(msgs, i);

                  return Column(
                    children: [
                      if (showDate) _DateDivider(date: msg.createdAt),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildBubble(msg, isUser),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // ── Sending indicator ──────────────────────────────────
          Obx(() => _ctrl.isSending.value
              ? Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: const [
                SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Sending…',
                    style: TextStyle(
                        fontSize: 11, color: Colors.black45)),
              ],
            ),
          )
              : const SizedBox.shrink()),

          _bottomInputField(),
        ],
      ),
    );
  }

  // ── Bubble builder ─────────────────────────────────────────────

  Widget _buildBubble(ChatMessage msg, bool isUser) {
    if (msg.type == MessageType.text) {
      return ChatBubble(
        text: msg.text,
        isUser: isUser,
        time: _formatTime(msg.createdAt),
        isRead: msg.isRead,
      );
    } else {
      return MediaBubble(
        mediaUrl: msg.mediaUrl,
        isUser: isUser,
        isVideo: msg.type == MessageType.video,
        time: _formatTime(msg.createdAt),
      );
    }
  }

  bool _shouldShowDateDivider(List<ChatMessage> msgs, int i) {
    if (i == 0) return true;
    final prev = msgs[i - 1].createdAt;
    final curr = msgs[i].createdAt;
    return curr.day != prev.day ||
        curr.month != prev.month ||
        curr.year != prev.year;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  // ── Input bar ──────────────────────────────────────────────────

  Widget _bottomInputField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl.messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: TextStyle(color: XColors.grey, fontSize: 12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _ctrl.sendText(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _ctrl.pickAndSendMedia,
              child: const Icon(Iconsax.gallery, size: 20, color: XColors.black),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _ctrl.sendText,
              child: Transform.rotate(
                angle: -0.6,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Icon(Iconsax.send_1, size: 20, color: XColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── More options menu ──────────────────────────────────────────

  void _showMoreOptions() {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(overlay.size.width - 60, 80, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 6,
      items: [
        if (!widget.isServiceProvider)
          PopupMenuItem(
            value: 1,
            child: Row(
              children: const [
                Icon(LucideIcons.circle_plus, color: XColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Create a Job Request',
                    style: TextStyle(color: XColors.grey)),
              ],
            ),
          ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: const [
              Icon(LucideIcons.trash_2, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete Chat', style: TextStyle(color: XColors.grey)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 1 && !widget.isServiceProvider) {
        Get.snackbar('Action', 'Create a Job Request tapped');
      } else if (value == 2) {
        _ctrl.deleteConversation(widget.conversationId);
      }
    });
  }
}

// ── Date divider ───────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

// ── Chat bubble ────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? XColors.lighterTint : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(color: XColors.black, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(time,
                style:
                const TextStyle(fontSize: 10, color: Colors.black45)),
            if (isUser) ...[
              const SizedBox(width: 4),
              Icon(
                isRead ? Icons.done_all : Icons.done,
                size: 12,
                color: isRead ? XColors.primary : Colors.black38,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Media bubble ───────────────────────────────────────────────────

class MediaBubble extends StatelessWidget {
  final String? mediaUrl;
  final bool isUser;
  final bool isVideo;
  final String time;

  const MediaBubble({
    super.key,
    required this.mediaUrl,
    required this.isUser,
    this.isVideo = false,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (mediaUrl != null) {
              Get.to(() => FullScreenMediaViewer(
                url: mediaUrl!,
                isVideo: isVideo,
              ));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.black12,
                  child: mediaUrl != null
                      ? (isVideo
                      ? _VideoThumbnail(url: mediaUrl!)
                      : CachedNetworkImage(
                    imageUrl: mediaUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image),
                  ))
                      : const Center(child: CircularProgressIndicator()),
                ),
                if (isVideo)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        size: 40, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }
}

// Simple static thumbnail for remote videos
class _VideoThumbnail extends StatelessWidget {
  final String url;
  const _VideoThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    // For a real thumbnail you'd use video_thumbnail package.
    // Using a placeholder icon for now.
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white54, size: 48),
      ),
    );
  }
}