// ─────────────────────────────────────────────────────────────────────────────
// FirebaseNotificationService  —  self-contained, copy-paste portable module
//
// DEPENDENCIES (add to pubspec.yaml):
//   firebase_core: ^3.1.0
//   firebase_messaging: ^15.2.5
//   flutter_local_notifications: ^18.0.1
//
// ANDROID SETUP:
//   android/app/src/main/AndroidManifest.xml — inside <application>:
//     <meta-data
//       android:name="com.google.firebase.messaging.default_notification_channel_id"
//       android:value="fcm_default_channel"/>
//   Make sure google-services.json is placed in android/app/.
//
// iOS SETUP:
//   - Add Push Notifications + Background Modes (remote notifications) in Xcode
//   - Place GoogleService-Info.plist in ios/Runner/
//   - Run: flutter pub run firebase_messaging --apple-init (optional helper)
//
// HOW TO USE — 3 steps:
//
//   STEP 1: Call the top-level background handler registrar BEFORE runApp().
//           The function `firebaseMessagingBackgroundHandler` at the bottom of
//           this file is already annotated with @pragma('vm:entry-point').
//           Just import this file; no extra work needed.
//
//   STEP 2: Initialize Firebase and this service in main():
//
//     import 'package:firebase_core/firebase_core.dart';
//     import 'core/services/notifications/firebase_notification_service.dart';
//
//     void main() async {
//       WidgetsFlutterBinding.ensureInitialized();
//       await Firebase.initializeApp();
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//       await FirebaseNotificationService.instance.initialize(
//         onMessageTap: (msg) {
//           // Navigate or handle tap here.
//           Get.toNamed('/notification-detail', arguments: msg);
//         },
//       );
//       runApp(const MyApp());
//     }
//
//   STEP 3 (optional): Subscribe / unsubscribe from topics anywhere:
//
//     FirebaseNotificationService.instance.subscribeToTopic('announcements');
//     FirebaseNotificationService.instance.unsubscribeFromTopic('announcements');
//
//   Access the FCM token:
//     final token = await FirebaseNotificationService.instance.getToken();
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/utils/local_storage/storage_helper.dart';
import 'local_notification_service.dart';
import 'notification_message_model.dart';

// ─── Background handler ───────────────────────────────────────────────────────
// Must be a TOP-LEVEL function (not a class method).
// The @pragma annotation ensures it survives tree-shaking in release builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() is called automatically by the plugin in isolate.
  // Put any background processing here (e.g. write to local DB).
  log('[FCM] background/terminated: ${message.messageId}');
}

// ─── Main service ─────────────────────────────────────────────────────────────
class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  void Function(NotificationMessageModel)? _onMessageTap;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> initialize({
    /// Called when the user taps a notification (foreground or system tray).
    void Function(NotificationMessageModel)? onMessageTap,
  }) async {
    _onMessageTap = onMessageTap;

    // 1. Request permission (iOS + Android 13+).
    await _requestPermission();

    // 2. Init local notification plugin for foreground display.
    await LocalNotificationService.instance.init(
      onTap: onMessageTap,
    );

    // 3. Handle foreground messages.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 4. App opened from background via notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

    // 5. App was TERMINATED — check if launched from a notification.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTapped(initial);

    // 6. iOS: show notification while app is in foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    log('[FCM] initialized. Token: ${await getToken()}');

    // 7. Re-register with the server whenever FCM rotates the token.
    //    Initial registration happens in _handleLoginSuccess() after the JWT
    //    is in storage so ApiService can attach the Authorization header.
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> _onTokenRefresh(String newToken) async {
    final isLoggedIn = await StorageHelper.getLoginStatus();
    if (isLoggedIn) await registerToken(newToken);
  }

  // ── Foreground message ─────────────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    log('[FCM] foreground: ${message.messageId}');
    final n = message.notification;
    if (n == null) return;

    // Android doesn't auto-display when app is open — show via local plugin.
    await LocalNotificationService.instance.show(
      n.title ?? '',
      n.body ?? '',
      data: Map<String, dynamic>.from(message.data),
      imageUrl: n.android?.imageUrl ?? n.apple?.imageUrl,
    );
  }

  // ── Tap handler ────────────────────────────────────────────────────────────

  void _onNotificationTapped(RemoteMessage message) {
    if (_onMessageTap == null) return;
    final n = message.notification;
    _onMessageTap!(
      NotificationMessageModel(
        title: n?.title ?? '',
        body: n?.body ?? '',
        imageUrl: n?.android?.imageUrl ?? n?.apple?.imageUrl,
        data: Map<String, dynamic>.from(message.data),
      ),
    );
  }

  // ── Permission ─────────────────────────────────────────────────────────────

  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    log('[FCM] permission: ${settings.authorizationStatus}');
    return granted;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the current FCM registration token.
  ///
  /// On iOS, `getToken()` can hang or throw until the APNs token is available
  /// (it never arrives on the iOS Simulator, which has no push support). Guard
  /// against that so this call can never block app startup.
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          log('[FCM] APNs token unavailable (e.g. Simulator); skipping getToken.');
          return null;
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      log('[FCM] getToken error: $e');
      return null;
    }
  }

  /// Sends the FCM token to the server.
  /// Call this right after login (once the JWT bearer token is in storage).
  /// userId and branchId are read from the JWT by the server — body sends 0.
  Future<void> registerToken(String token) async {
    try {
      await ApiService().postJson(
        Endpoints.saveFirebaseToken(),
        {
          'branchId': 0,
          'userId': 0,
          'fcmToken': token,
          'deviceType': Platform.isIOS ? 'iOS' : 'Android',
        },
      );
      log('[FCM] token registered');
    } catch (e) {
      log('[FCM] registerToken error: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    log('[FCM] subscribed: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    log('[FCM] unsubscribed: $topic');
  }

  /// Delete the current token (e.g. on logout).
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    log('[FCM] token deleted');
  }
}
