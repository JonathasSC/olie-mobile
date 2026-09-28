import 'package:flutter/material.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/theme/app_theme.dart';
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
      case AppNotificationType.wearItemReplacementApproaching:
        return Icons.autorenew;
      case AppNotificationType.whatsAppDisconnected:
        return Icons.link_off;
      case AppNotificationType.inquiryFinished:
        return Icons.forum_outlined;
    }
  }

  Color _colorFor(OliePalette p, AppNotificationType type) {
    switch (type) {
      case AppNotificationType.purchaseDateApproaching:
      case AppNotificationType.sufficientBalance:
        return p.money;
      case AppNotificationType.wearItemReplacementApproaching:
      case AppNotificationType.inquiryFinished:
        return p.olive;
      case AppNotificationType.whatsAppDisconnected:
        return p.critical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final color = _colorFor(p, notification.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_iconFor(notification.type), size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${notification.type.label} · ${formatDateTime(notification.receivedAt)}',
                  style: OlieText.data(context, size: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
