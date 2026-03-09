import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/models/chat_conversation_model.dart';
import '../../../../domain/models/message_model.dart';
import '../../../../domain/repos/chat_repository.dart';
import '../../../../services/chat_notification_service.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  final _repo = ChatRepository.instance;
  final _notif = ChatNotificationService.instance;
  final _auth = FirebaseAuth.instance;

  // ── Current user ───────────────────────────────────────────────

  String get myId => _auth.currentUser?.uid ?? '';
  String get myName =>
      _auth.currentUser?.displayName ?? 'You';
  String get myAvatar => _auth.currentUser?.photoURL ?? '';

  // ── Reactive state ─────────────────────────────────────────────

  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxBool isSending = false.obs;
  final RxString activeConversationId = ''.obs;

  // UI controllers owned here so they survive hot-reload
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _listenToConversations();
    _refreshFcmToken();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Conversation list ──────────────────────────────────────────

  void _listenToConversations() {
    if (myId.isEmpty) return;
    isLoadingConversations.value = true;
    _repo.conversationsStream(myId).listen((list) {
      conversations.value = list;
      isLoadingConversations.value = false;
    });
  }

  // ── Open / create a chat ───────────────────────────────────────

  /// Call this from the ServiceProviderProfileScreen FAB.
  /// [otherFcmToken] comes from the fixer's profile document.
  Future<void> openChat({
    required String otherId,
    required String otherName,
    required String otherAvatar,
    String? otherFcmToken,
    String? myFcmToken,
  }) async {
    final convId = await _repo.ensureConversation(
      myId: myId,
      otherId: otherId,
      myName: myName,
      otherName: otherName,
      myAvatar: myAvatar,
      otherAvatar: otherAvatar,
      myFcmToken: myFcmToken ?? await _notif.getToken(),
      otherFcmToken: otherFcmToken,
    );

    activeConversationId.value = convId;
    _listenToMessages(convId);
    await _repo.markAsRead(convId, myId);
  }

  // ── Messages ───────────────────────────────────────────────────

  void _listenToMessages(String convId) {
    _repo.messagesStream(convId).listen((msgs) {
      messages.value = msgs;
      _scrollToBottom();
    });
  }

  Future<void> sendText() async {
    final text = messageController.text.trim();
    if (text.isEmpty || activeConversationId.isEmpty) return;

    // Derive receiverId directly from the conversation ID (uid1_uid2 format)
    // so it works even before the conversation stream has emitted
    final receiverId = _receiverIdFromConvId(activeConversationId.value);
    if (receiverId.isEmpty) {
      debugPrint('▶ sendText: could not resolve receiverId');
      return;
    }

    messageController.clear();
    isSending.value = true;

    try {
      await _repo.sendTextMessage(
        convId: activeConversationId.value,
        senderId: myId,
        receiverId: receiverId,
        text: text,
      );
      // Notification — best-effort, use conv from stream if available
      await _sendNotification(text, _currentConversation);
    } finally {
      isSending.value = false;
    }
  }

  /// Extracts the other user's ID from a conversation ID like "uid1_uid2".
  String _receiverIdFromConvId(String convId) {
    final parts = convId.split('_');
    if (parts.length != 2) return '';
    return parts[0] == myId ? parts[1] : parts[0];
  }

  Future<void> pickAndSendMedia() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.media, allowMultiple: false);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final isVideo =
        file.path.endsWith('.mp4') || file.path.endsWith('.mov');
    final type = isVideo ? MessageType.video : MessageType.image;

    final receiverId = _receiverIdFromConvId(activeConversationId.value);
    if (receiverId.isEmpty) return;

    isSending.value = true;
    try {
      await _repo.sendMediaMessage(
        convId: activeConversationId.value,
        senderId: myId,
        receiverId: receiverId,
        file: file,
        type: type,
      );
      await _sendNotification(
          type == MessageType.image ? '📷 Photo' : '🎥 Video',
          _currentConversation);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> markCurrentChatRead() async {
    if (activeConversationId.isEmpty) return;
    await _repo.markAsRead(activeConversationId.value, myId);
  }

  Future<void> deleteConversation(String convId) async {
    await _repo.deleteConversation(convId, myId);
    Get.back();
  }

  // ── Helpers ────────────────────────────────────────────────────

  ChatConversation? get _currentConversation {
    try {
      return conversations
          .firstWhere((c) => c.id == activeConversationId.value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _sendNotification(
      String preview, ChatConversation? conv) async {
    if (conv == null) return;
    final otherId = conv.otherUserId(myId);
    final token = conv.fcmTokens[otherId];
    if (token == null || token.isEmpty) return;

    await _notif.sendMessageNotification(
      recipientFcmToken: token,
      senderName: myName,
      messagePreview: preview,
      conversationId: activeConversationId.value,
      senderAvatar: myAvatar,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _refreshFcmToken() async {
    // Listen for token refreshes and update all conversations
    _notif.onTokenRefresh.listen((token) async {
      for (final conv in conversations) {
        await _repo.updateFcmToken(conv.id, myId, token);
      }
    });
  }

  /// Open an existing conversation from the AllChat list (no Firestore write needed).
  Future<void> openChatFromConversation(ChatConversation conv) async {
    activeConversationId.value = conv.id;
    messages.clear();
    _listenToMessages(conv.id);
    await _repo.markAsRead(conv.id, myId);
  }

  // ── Search conversations ───────────────────────────────────────

  RxString searchQuery = ''.obs;

  List<ChatConversation> get filteredConversations {
    if (searchQuery.isEmpty) return conversations;
    final q = searchQuery.value.toLowerCase();
    return conversations
        .where((c) =>
    c.otherUserName(myId).toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q))
        .toList();
  }
}