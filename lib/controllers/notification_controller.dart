import 'dart:async';
import 'package:get/get.dart';
import '../data/repos/notification_repository.dart';
import '../domain/models/app_notification_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repo;
  NotificationController({required NotificationRepository repo}) : _repo = repo;

  final RxList<AppNotificationModel> notifications = <AppNotificationModel>[].obs;
  StreamSubscription<List<AppNotificationModel>>? _sub;

  void bindNotifications(String userId) {
    _sub?.cancel();
    _sub = _repo.watchUserNotifications(userId).listen(notifications.assignAll);
  }

  Future<void> markRead(String notificationId) => _repo.markAsRead(notificationId);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
