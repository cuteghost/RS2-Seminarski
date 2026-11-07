import 'package:ebooking/utils/server_time.dart';

enum NotificationType {
  reservationCreated(1),
  reservationStatusChanged(2),
  reservationCancelled(3),
  paymentCompleted(4),
  passwordChanged(5),
  accommodationPromoted(6),
  unknown(0);

  const NotificationType(this.value);

  final int value;

  static NotificationType fromValue(int value) => NotificationType.values
      .firstWhere((type) => type.value == value, orElse: () => unknown);
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedEntityId;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.relatedEntityId,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.fromValue((json['type'] as num?)?.toInt() ?? 0),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      relatedEntityId: json['relatedEntityId'] as String?,
      createdAt: parseServerUtc(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
