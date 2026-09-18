import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/entities/app_notification_type.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.message,
    super.plannedItemId,
    required super.receivedAt,
  });

  /// Aceita tanto o formato do histórico (`sentAt`) quanto o do payload
  /// recebido em tempo real via WebSocket (`createdAt`) — ver `API.md`.
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final timestamp = (json['sentAt'] ?? json['createdAt']) as String;
    return AppNotificationModel(
      id: json['id'] as String,
      type: AppNotificationType.fromApiValue(json['type'] as String),
      message: json['message'] as String,
      plannedItemId: json['plannedItemId'] as String?,
      receivedAt: DateTime.parse(timestamp),
    );
  }
}
