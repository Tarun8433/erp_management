class PushNotificationModel {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? notificationType;
  final String? referenceId;
  final String? deepLink;
  final bool isRead;
  final DateTime sentOn;
  final DateTime createdOn;

  PushNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.notificationType,
    this.referenceId,
    this.deepLink,
    required this.isRead,
    required this.sentOn,
    required this.createdOn,
  });

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      notificationType: json['notificationType']?.toString(),
      referenceId: json['referenceId']?.toString(),
      deepLink: json['deepLink']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      sentOn: DateTime.tryParse(json['sentOn']?.toString() ?? '') ?? DateTime.now(),
      createdOn: DateTime.tryParse(json['createdOn']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  PushNotificationModel copyWith({bool? isRead}) => PushNotificationModel(
        id: id,
        title: title,
        body: body,
        imageUrl: imageUrl,
        notificationType: notificationType,
        referenceId: referenceId,
        deepLink: deepLink,
        isRead: isRead ?? this.isRead,
        sentOn: sentOn,
        createdOn: createdOn,
      );
}
