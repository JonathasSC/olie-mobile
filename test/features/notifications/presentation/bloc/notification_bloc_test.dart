import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/entities/app_notification_type.dart';
import 'package:olie/features/notifications/domain/usecases/disconnect_realtime_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/get_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/watch_realtime_notifications.dart';
import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockWatchRealtimeNotifications extends Mock
    implements WatchRealtimeNotifications {}

class MockDisconnectRealtimeNotifications extends Mock
    implements DisconnectRealtimeNotifications {}

void main() {
  late MockGetNotifications getNotifications;
  late MockWatchRealtimeNotifications watchRealtimeNotifications;
  late MockDisconnectRealtimeNotifications disconnectRealtimeNotifications;
  late StreamController<AppNotification> realtimeController;

  final notification = AppNotification(
    id: 'uuid',
    type: AppNotificationType.sufficientBalance,
    message: 'Você já tem saldo suficiente para a compra.',
    plannedItemId: 'planned-uuid',
    receivedAt: DateTime.utc(2026, 11, 28, 12),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getNotifications = MockGetNotifications();
    watchRealtimeNotifications = MockWatchRealtimeNotifications();
    disconnectRealtimeNotifications = MockDisconnectRealtimeNotifications();
    realtimeController = StreamController<AppNotification>.broadcast();
    when(
      () => watchRealtimeNotifications(),
    ).thenAnswer((_) => realtimeController.stream);
    when(
      () => disconnectRealtimeNotifications(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  tearDown(() => realtimeController.close());

  NotificationBloc buildBloc() => NotificationBloc(
        getNotifications: getNotifications,
        watchRealtimeNotifications: watchRealtimeNotifications,
        disconnectRealtimeNotifications: disconnectRealtimeNotifications,
      );

  blocTest<NotificationBloc, NotificationState>(
    'emite [loading, success] quando o histórico é carregado',
    build: () {
      when(
        () => getNotifications(const NoParams()),
      ).thenAnswer((_) async => Right([notification]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const NotificationsRequested()),
    expect: () => [
      const NotificationState(status: NotificationStatus.loading),
      NotificationState(
        status: NotificationStatus.success,
        notifications: [notification],
      ),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'emite [failure] quando o carregamento do histórico falha',
    build: () {
      when(() => getNotifications(const NoParams())).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Erro ao comunicar com o servidor.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const NotificationsRequested()),
    expect: () => [
      const NotificationState(status: NotificationStatus.loading),
      const NotificationState(
        status: NotificationStatus.failure,
        errorMessage: 'Erro ao comunicar com o servidor.',
      ),
    ],
  );

  blocTest<NotificationBloc, NotificationState>(
    'prepende notificações recebidas em tempo real à lista',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const RealtimeConnectionRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      realtimeController.add(notification);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await realtimeController.close();
    },
    expect: () => [
      NotificationState(
        notifications: [notification],
        lastReceived: notification,
      ),
    ],
  );
}
