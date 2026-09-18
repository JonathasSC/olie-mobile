import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/repositories/notification_repository.dart';

/// Não implementa [UseCase] pois expõe um [Stream] contínuo em vez de um
/// resultado único — não se encaixa no formato `Future<Either<Failure, T>>`.
class WatchRealtimeNotifications {
  final NotificationRepository repository;

  WatchRealtimeNotifications(this.repository);

  Stream<AppNotification> call() => repository.watchRealtimeNotifications();
}
