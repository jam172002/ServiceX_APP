import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatNotificationService {
  ChatNotificationService._();
  static final ChatNotificationService instance = ChatNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _sendNotificationEndpoint =
      'https://us-central1-servicex-220b5.cloudfunctions.net/sendChatNotification';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Chat channel
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'chat_channel',
        'Chat Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
      ),
    );

    // Quotes channel
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'quotes_channel',
        'New Quotes',
        description: 'Notifications when a service provider sends a quote',
        importance: Importance.high,
      ),
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refreshes and re-save automatically
    _messaging.onTokenRefresh.listen((newToken) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) _persistToken(uid, newToken);
    });
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Call this right after the client user logs in.
  Future<void> saveTokenForClient(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _persistToken(uid, token);
      debugPrint('✅ Client FCM token saved for $uid');
    } catch (e) {
      debugPrint('❌ Failed to save client FCM token: $e');
    }
  }

  Future<void> _persistToken(String uid, String token) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  // ── Send chat notification (HTTP — called from app) ───────────────────────

  Future<void> sendMessageNotification({
    required String recipientFcmToken,
    required String senderName,
    required String messagePreview,
    required String conversationId,
    required String senderAvatar,
  }) async {
    if (recipientFcmToken.isEmpty) return;

    try {
      await http.post(
        Uri.parse(_sendNotificationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': recipientFcmToken,
          'title': senderName,
          'body': messagePreview,
          'data': {
            'type': 'chat_message',
            'conversationId': conversationId,
            'senderName': senderName,
            'senderAvatar': senderAvatar,
          },
        }),
      );
    } catch (e) {
      debugPrint('FCM send error: $e');
    }
  }

  // ── Foreground message handler ────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? 'chat_message';

    final channelId =
    type == 'new_quote' ? 'quotes_channel' : 'chat_channel';
    final channelName =
    type == 'new_quote' ? 'New Quotes' : 'Chat Messages';

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Show sender avatar as large icon if available
          largeIcon: (data['senderAvatar'] != null &&
              (data['senderAvatar'] as String).isNotEmpty)
              ? DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
              : null,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  // ── Background / tap handler ──────────────────────────────────────────────

  void _handleNotificationTap(RemoteMessage message) {
    _routeFromData(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _routeFromData(data);
    } catch (e) {
      debugPrint('Local notification tap parse error: $e');
    }
  }

  void _routeFromData(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'chat_message':
        Get.toNamed(
          '/chat',
          arguments: {'conversationId': data['conversationId']},
        );
        break;

      case 'new_quote':
      // Navigate to the job detail screen to see the incoming quote.
      // Fetch the job doc so the screen has full data.
        final jobId = data['jobId'] as String?;
        if (jobId == null || jobId.isEmpty) return;

        _db.collection('job_requests').doc(jobId).get().then((snap) {
          if (!snap.exists) return;
          // Adjust the route name / screen to match your client app's
          // job detail screen route.
          Get.toNamed('/job-detail', arguments: snap);
        });
        break;

      default:
        debugPrint('Unknown notification type: $type');
    }
  }
}