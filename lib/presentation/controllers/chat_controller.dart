import 'dart:async';
import 'package:get/get.dart';
import '../../domain/repos/chat_repository.dart';
import '../../domain/models/chat_room_model.dart';
import '../../domain/models/message_model.dart';

class ChatController extends GetxController {
  final ChatRepository _repo;
  ChatController({required ChatRepository repo}) : _repo = repo;

  final RxList<ChatRoomModel> rooms = <ChatRoomModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  StreamSubscription<List<ChatRoomModel>>? _roomsSub;
  StreamSubscription<List<MessageModel>>? _msgsSub;

  void bindUserRooms(String userId) {
    _roomsSub?.cancel();
    _roomsSub = _repo.watchUserRooms(userId).listen(rooms.assignAll);
  }

  void bindProviderRooms(String providerId) {
    _roomsSub?.cancel();
    _roomsSub = _repo.watchProviderRooms(providerId).listen(rooms.assignAll);
  }

  Future<String> createOrGetRoom({
    required String userId,
    required String providerId,
  }) => _repo.createOrGetRoom(userId: userId, providerId: providerId);

  void bindMessages(String roomId, {int limit = 100}) {
    _msgsSub?.cancel();
    _msgsSub = _repo
        .watchMessages(roomId, limit: limit)
        .listen(messages.assignAll);
  }

  Future<void> sendText({
    required String roomId,
    required String senderId,
    required String text,
  }) {
    final msg = MessageModel(
      id: '',
      chatRoomId: roomId,
      senderId: senderId,
      text: text,
      mediaUrl: null,
      sentAt: DateTime.now(),
    );
    return _repo.sendMessage(roomId: roomId, message: msg);
  }

  Future<void> sendMedia({
    required String roomId,
    required String senderId,
    required String mediaUrl,
    String text = '',
  }) {
    final msg = MessageModel(
      id: '',
      chatRoomId: roomId,
      senderId: senderId,
      text: text,
      mediaUrl: mediaUrl,
      sentAt: DateTime.now(),
    );
    return _repo.sendMessage(roomId: roomId, message: msg);
  }

  Future<void> clearChat(String roomId) => _repo.clearChat(roomId);

  @override
  void onClose() {
    _roomsSub?.cancel();
    _msgsSub?.cancel();
    super.onClose();
  }
}
