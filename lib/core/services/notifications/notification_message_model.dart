// ─────────────────────────────────────────────────────────────────────────────
// NotificationMessageModel
//
// HOW TO USE:
//   Built automatically by FirebaseNotificationService from RemoteMessage/
//   local-notification payloads.  Use it in your onTap / onMessage callbacks:
//
//     FirebaseNotificationService.instance.initialize(
//       onMessageTap: (msg) {
//         print(msg.title);
//         print(msg.data);   // original payload Map
//       },
//     );
// ─────────────────────────────────────────────────────────────────────────────

class NotificationMessageModel {
  final String title;
  final String body;
  final String? imageUrl;

  /// Original key-value payload from the FCM data or local-notification extras.
  final Map<String, dynamic> data;

  const NotificationMessageModel({
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
  });

  factory NotificationMessageModel.fromMap(Map<String, dynamic> map) {
    return NotificationMessageModel(
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      imageUrl: map['imageUrl'] as String?,
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'data': data,
      };
}
