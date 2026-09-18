part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;

  /// Última notificação recebida em tempo real — usada só para acionar uma
  /// reação pontual na UI (ex.: SnackBar), via `listenWhen` comparando este
  /// campo entre estados.
  final AppNotification? lastReceived;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.lastReceived,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
    AppNotification? lastReceived,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      lastReceived: lastReceived ?? this.lastReceived,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage, lastReceived];
}
