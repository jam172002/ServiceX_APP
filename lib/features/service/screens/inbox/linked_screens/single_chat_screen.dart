import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:servicex_client_app/common/widgets/appbar/custom_chat_appbar.dart';
import 'package:servicex_client_app/common/widgets/others/full_screen_media_viewer_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

class SingleChatScreen extends StatefulWidget {
  final bool isServiceProvider;

  const SingleChatScreen({super.key, required this.isServiceProvider});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  /// Add a text message
  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true, 'time': _getCurrentTime()});
    });

    _messageController.clear();
    _scrollToBottom();
  }

  /// Pick image/video from gallery
  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      bool isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov');

      setState(() {
        _messages.add({
          'file': file,
          'isVideo': isVideo,
          'isUser': true,
          'time': _getCurrentTime(),
        });
      });

      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    return "$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomChatAppBar(
        name: 'Muhammad Sufyan',
        location: 'Model Town, Bahawalpur',
        country: 'Pakistan',
        imagePath: XImages.serviceProvider,
        onMoreTap: _showMoreOptions,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];

                if (msg.containsKey('file')) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: MediaBubble(
                      mediaPath: msg['file'].path,
                      isUser: msg['isUser'],
                      isVideo: msg['isVideo'] ?? false,
                      time: msg['time'],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ChatBubble(
                    text: msg['text'],
                    isUser: msg['isUser'],
                    time: msg['time'],
                  ),
                );
              },
            ),
          ),
          _bottomInputField(),
        ],
      ),
    );
  }

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
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: TextStyle(color: XColors.grey, fontSize: 12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _pickMedia,
              child: const Icon(
                Iconsax.gallery,
                size: 20,
                color: XColors.black,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _sendTextMessage,
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
                Text(
                  'Create a Job Request',
                  style: TextStyle(color: XColors.grey),
                ),
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
        setState(() => _messages.clear());
        Get.snackbar('Action', 'Chat deleted');
      }
    });
  }
}

/// CHAT BUBBLE
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
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
        Text(time, style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }
}

/// MEDIA BUBBLE
class MediaBubble extends StatefulWidget {
  final String mediaPath;
  final bool isUser;
  final bool isVideo;
  final String time;

  const MediaBubble({
    super.key,
    required this.mediaPath,
    required this.isUser,
    this.isVideo = false,
    required this.time,
  });

  @override
  State<MediaBubble> createState() => _MediaBubbleState();
}

class _MediaBubbleState extends State<MediaBubble> {
  VideoPlayerController? _videoController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          setState(() => _initialized = true);
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Get.to(
              () => FullScreenMediaViewer(
                url: widget.mediaPath,
                isVideo: widget.isVideo,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(widget.isUser ? 16 : 0),
              bottomRight: Radius.circular(widget.isUser ? 0 : 16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width * 0.65,
                  color: Colors.black12,
                  child: widget.isVideo
                      ? _initialized
                            ? VideoPlayer(_videoController!)
                            : const Center(child: CircularProgressIndicator())
                      : Image.file(File(widget.mediaPath), fit: BoxFit.cover),
                ),
                if (widget.isVideo)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.time,
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    );
  }
}
