// ─────────────────────────────────────────────────────────────────────────────
// LocalNotificationService
//
// Wraps flutter_local_notifications.  Displays a notification while the app
// is in the FOREGROUND (FCM doesn't auto-display in that case on Android).
//
// HOW TO USE (FirebaseNotificationService calls this internally — you normally
// don't need to call it yourself):
//
//   await LocalNotificationService.instance.init(
//     onTap: (payload) { /* handle tap */ },
//   );
//   await LocalNotificationService.instance.show(title, body, payload: 'route');
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_message_model.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  void Function(NotificationMessageModel)? _onTap;

  static const _channelId = 'fcm_default_channel';
  static const _channelName = 'General Notifications';
  static const _channelDescription = 'School ERP push notifications';

  Future<void> init({
    void Function(NotificationMessageModel)? onTap,
  }) async {
    _onTap = onTap;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onResponse,
    );

    // Create the Android notification channel (required for Android 8+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  void _onResponse(NotificationResponse response) {
    if (_onTap == null) return;
    try {
      final raw = jsonDecode(response.payload ?? '{}') as Map<String, dynamic>;
      _onTap!(NotificationMessageModel.fromMap(raw));
    } catch (e) {
      log('[LocalNotificationService] tap parse error: $e');
    }
  }

  Future<void> show(
    String title,
    String body, {
    Map<String, dynamic> data = const {},
    String? imageUrl,
  }) async {
    final payload = jsonEncode(
      NotificationMessageModel(
        title: title,
        body: body,
        imageUrl: imageUrl,
        data: data,
      ).toMap(),
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        // Show large icon from network URL when available.
        styleInformation: imageUrl != null
            ? BigPictureStyleInformation(
                DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              )
            : const DefaultStyleInformation(true, true),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Check / request runtime permission (Android 13+).
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    return await android.requestNotificationsPermission() ?? false;
  }
}
