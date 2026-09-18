import 'package:flutter/material.dart';

import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/entities/app_notification_type.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification notification;

  const NotificationListItem({super.key, required this.notification});

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.purchaseDateApproaching:
        return Icons.event_outlined;
      case AppNotificationType.sufficientBalance:
        return Icons.savings_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(_iconFor(notification.type))),
      title: Text(notification.message),
      subtitle: Text(
        '${notification.type.label} · ${_formatDate(notification.receivedAt)}',
      ),
    );
  }
}
