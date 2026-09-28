part of 'whatsapp_bloc.dart';

enum WhatsAppStatus { initial, loading, ready, failure }

class WhatsAppState extends Equatable {
  final WhatsAppStatus status;
  final WhatsAppConnection connection;

  /// Uma chamada (conectar/desconectar) está em andamento.
  final bool busy;
  final String? errorMessage;

  const WhatsAppState({
    this.status = WhatsAppStatus.initial,
    this.connection = const WhatsAppConnection.disconnected(),
    this.busy = false,
    this.errorMessage,
  });

  WhatsAppState copyWith({
    WhatsAppStatus? status,
    WhatsAppConnection? connection,
    bool? busy,
    String? errorMessage,
  }) {
    return WhatsAppState(
      status: status ?? this.status,
      connection: connection ?? this.connection,
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, connection, busy, errorMessage];
}
