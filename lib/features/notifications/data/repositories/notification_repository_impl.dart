import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/notifications/data/datasources/notification_realtime_data_source.dart';
import 'package:olie/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationRealtimeDataSource realtimeDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.realtimeDataSource,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return Right(notifications);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<AppNotification> watchRealtimeNotifications() {
    unawaited(realtimeDataSource.connect());
    return realtimeDataSource.stream;
  }

  @override
  Future<void> disconnectRealtime() => realtimeDataSource.disconnect();
}
