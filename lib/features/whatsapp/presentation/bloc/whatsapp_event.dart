part of 'whatsapp_bloc.dart';

abstract class WhatsAppEvent extends Equatable {
  const WhatsAppEvent();

  @override
  List<Object?> get props => [];
}

/// Carrega o estado e passa a acompanhar as mudanças em tempo real.
class WhatsAppStarted extends WhatsAppEvent {
  const WhatsAppStarted();
}

class WhatsAppRefreshed extends WhatsAppEvent {
  const WhatsAppRefreshed();
}

/// Inicia a conexão: com sessão salva conecta direto, senão mostra QR code.
class WhatsAppConnectRequested extends WhatsAppEvent {
  const WhatsAppConnectRequested();
}

class WhatsAppDisconnectRequested extends WhatsAppEvent {
  const WhatsAppDisconnectRequested();
}
