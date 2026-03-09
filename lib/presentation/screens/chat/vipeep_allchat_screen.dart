import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/presentation/widgets/allchat_screen_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import '../../../domain/models/chat_conversation_model.dart';
import 'controller/chat_controller.dart';
import 'single_chat_screen.dart';

class VipeepAllChatScreen extends StatelessWidget {
  const VipeepAllChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    final ctrl = ChatController.to;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'All Chats',
          style: TextStyle(
            color: XColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // ── Search ────────────────────────────────────────────
            SearchWithFilter(
              horPadding: 0,
              hintText: 'Search...',
              onChanged: (val) => ctrl.searchQuery.value = val,
            ),
            const SizedBox(height: 16),

            // ── Conversation list ─────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoadingConversations.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final convs = ctrl.filteredConversations;

                if (convs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No conversations yet.\nStart chatting from a provider profile!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight + 20),
                  itemCount: convs.length,
                  itemBuilder: (_, i) {
                    final conv = convs[i];
                    return _ConversationTile(conv: conv, ctrl: ctrl);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conversation tile ──────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ChatConversation conv;
  final ChatController ctrl;

  const _ConversationTile({required this.conv, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final myId = ctrl.myId;
    final name = conv.otherUserName(myId);
    final avatar = conv.otherUserAvatar(myId);
    final unread = conv.myUnreadCount(myId);

    return AllChatScreenCard(
      name: name,
      lastMessage: conv.lastMessage.isEmpty ? 'Say hello!' : conv.lastMessage,
      date: conv.formattedTime,
      time: '',
      unreadCount: unread,
      avatarUrl: avatar,
      onTap: () async {
        // Activate this conversation in the controller
        ctrl.activeConversationId.value = conv.id;
        ctrl.messages.clear();

        // Tap directly into the stream for this existing conversation
        await ctrl.openChatFromConversation(conv);

        Get.to(() => SingleChatScreen(
          conversationId: conv.id,
          otherUserId: conv.otherUserId(myId),
          otherUserName: name,
          otherUserAvatar: avatar,
          isServiceProvider: false, // client side
        ));
      },
    );
  }
}