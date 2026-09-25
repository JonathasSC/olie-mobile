import 'package:equatable/equatable.dart';

import 'package:olie/features/notifications/domain/entities/app_notification_type.dart';

class AppNotification extends Equatable {
  final String id;
  final AppNotificationType type;
  final String message;
  final String? plannedItemId;
  final String? wearItemId;
  final DateTime receivedAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    this.plannedItemId,
    this.wearItemId,
    required this.receivedAt,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    message,
    plannedItemId,
    wearItemId,
    receivedAt,
  ];
}
