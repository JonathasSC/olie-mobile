import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  /// Conecta ao WebSocket (se ainda não conectado) e retorna o stream de
  /// notificações recebidas em tempo real enquanto a conexão estiver ativa.
  Stream<AppNotification> watchRealtimeNotifications();

  Future<void> disconnectRealtime();
}
