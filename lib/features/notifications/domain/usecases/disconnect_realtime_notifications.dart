import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notifications/domain/repositories/notification_repository.dart';

class DisconnectRealtimeNotifications implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  DisconnectRealtimeNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await repository.disconnectRealtime();
    return const Right(null);
  }
}
