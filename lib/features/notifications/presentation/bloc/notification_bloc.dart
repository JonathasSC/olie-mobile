import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/usecases/disconnect_realtime_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/get_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/watch_realtime_notifications.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final WatchRealtimeNotifications watchRealtimeNotifications;
  final DisconnectRealtimeNotifications disconnectRealtimeNotifications;

  NotificationBloc({
    required this.getNotifications,
    required this.watchRealtimeNotifications,
    required this.disconnectRealtimeNotifications,
  }) : super(const NotificationState()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<RealtimeConnectionRequested>(
      _onRealtimeConnectionRequested,
      transformer: (events, mapper) => events.take(1).asyncExpand(mapper),
    );
    on<RealtimeDisconnectionRequested>(_onRealtimeDisconnectionRequested);
  }

  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final result = await getNotifications(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: failure.message,
      )),
      (notifications) => emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
      )),
    );
  }

  Future<void> _onRealtimeConnectionRequested(
    RealtimeConnectionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await emit.forEach<AppNotification>(
      watchRealtimeNotifications(),
      onData: (notification) => state.copyWith(
        notifications: [notification, ...state.notifications],
        lastReceived: notification,
      ),
    );
  }

  Future<void> _onRealtimeDisconnectionRequested(
    RealtimeDisconnectionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await disconnectRealtimeNotifications(const NoParams());
  }
}
