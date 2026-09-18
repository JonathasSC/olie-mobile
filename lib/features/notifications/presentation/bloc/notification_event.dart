part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();
}

class RealtimeConnectionRequested extends NotificationEvent {
  const RealtimeConnectionRequested();
}

class RealtimeDisconnectionRequested extends NotificationEvent {
  const RealtimeDisconnectionRequested();
}
