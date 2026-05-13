---
name: firebase-expert
description: >
  Auto-invoke when working with Firebase in any part of this project: firebase_messaging,
  firebase_core, firebase_options.dart, Firebase Admin SDK (backend), FCM tokens, push
  notifications, Firestore (if added), Firebase Storage, or when the user mentions
  "FCM", "push notification", "Firebase", "firebase_admin", or "notification token".
---

# Firebase Expert Skill

You know Firebase inside out for this project's specific setup: Firebase Admin SDK on the backend (Node.js) and Firebase Messaging + Core on Flutter (gold/ and gold_admin/).

## This Project's Firebase Setup

**Backend (`backend/`):**
- Firebase Admin SDK initialized with a service account JSON file
- Used for: sending FCM push notifications to devices
- Service account file: `influnexa-5bb97-firebase-adminsdk-fbsvc-*.json` — **must never be committed to git**
- FCM tokens stored in `User.fcmToken` field in MongoDB

**Flutter (`gold/` and `gold_admin/`):**
- `firebase_core: ^3.6.0` — initialized in `main.dart` before `runApp()`
- `firebase_messaging: ^15.1.3` — push notifications
- `flutter_local_notifications: ^17.2.1` — show notification banners while app is in foreground
- `firebase_options.dart` — auto-generated config, acceptable to commit (public config, not private keys)

## Flutter Firebase Patterns

### Initialization order (main.dart) — order matters
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // MUST be first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### FCM Token registration
```dart
Future<void> registerFcmToken() async {
  // Request permission first — token is null without it on iOS
  final settings = await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.denied) return;

  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await _chatRepository.registerFcmToken(token);  // send to backend
  }

  // Refresh token when it changes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    _chatRepository.registerFcmToken(newToken);
  });
}
```

### Message handling (all three states)
```dart
// Foreground — app open
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show with flutter_local_notifications
  _showLocalNotification(message);
});

// Background tap — app in background, user tapped notification
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  _handleNotificationTap(message.data);
});

// Terminated — app was closed, opened via notification
final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
  _handleNotificationTap(initialMessage.data);
}
```

## Backend FCM Patterns

### Sending a push notification
```js
import admin from 'firebase-admin';

export const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken) return;  // user may not have a token — silent fail
  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(                // data values must be strings
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  } catch (error) {
    // Token may be expired — clean it up
    if (error.code === 'messaging/registration-token-not-registered') {
      await User.findByIdAndUpdate(userId, { $unset: { fcmToken: 1 } });
    }
    console.error('Push notification failed:', error.code);
    // Never throw — notification failure must not break the main operation
  }
};
```

### Sending to multiple tokens
```js
await admin.messaging().sendEachForMulticast({
  tokens: fcmTokens.filter(Boolean),  // remove null/undefined tokens
  notification: { title, body },
  data,
});
```

## Common Issues

- **Token is null on iOS:** `requestPermission()` must be called before `getToken()` — permission is required on iOS
- **Notifications not shown in foreground:** Must use `flutter_local_notifications` manually — Firebase only auto-shows when app is in background/terminated
- **Background handler must be top-level function:** `FirebaseMessaging.onBackgroundMessage(handler)` — `handler` cannot be a class method or closure
- **Data values must be strings:** `admin.messaging().send()` — all `data` map values must be `String`, not numbers or booleans
- **Expired tokens:** Handle `messaging/registration-token-not-registered` error by clearing the stored FCM token from the User document
