import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum WhatsAppConnectionStatus {
  disconnected,
  connecting,
  waitingQr,
  connected;

  static WhatsAppConnectionStatus fromApiValue(String value) {
    switch (value) {
      case 'DISCONNECTED':
        return WhatsAppConnectionStatus.disconnected;
      case 'CONNECTING':
        return WhatsAppConnectionStatus.connecting;
      case 'WAITING_QR':
        return WhatsAppConnectionStatus.waitingQr;
      case 'CONNECTED':
        return WhatsAppConnectionStatus.connected;
      default:
        throw ArgumentError('Status de conexão desconhecido: $value');
    }
  }

  String get label {
    switch (this) {
      case WhatsAppConnectionStatus.disconnected:
        return 'Desconectado';
      case WhatsAppConnectionStatus.connecting:
        return 'Conectando…';
      case WhatsAppConnectionStatus.waitingQr:
        return 'Aguardando leitura do QR code';
      case WhatsAppConnectionStatus.connected:
        return 'Conectado';
    }
  }
}

/// Sessão de WhatsApp do usuário (cada usuário do Olie tem a sua).
class WhatsAppConnection extends Equatable {
  final WhatsAppConnectionStatus status;

  /// PNG em data URL; só existe aguardando leitura do QR code.
  final String? qrCode;

  /// Número conectado (E.164); só existe quando conectado.
  final String? phone;

  /// Motivo da última desconexão (`LOGGED_OUT`, `QR_TIMEOUT`...).
  final String? reason;

  const WhatsAppConnection({
    required this.status,
    this.qrCode,
    this.phone,
    this.reason,
  });

  const WhatsAppConnection.disconnected()
    : status = WhatsAppConnectionStatus.disconnected,
      qrCode = null,
      phone = null,
      reason = null;

  bool get isConnected => status == WhatsAppConnectionStatus.connected;

  /// Imagem do QR code já decodificada, pronta para `Image.memory`.
  Uint8List? get qrCodeBytes {
    final data = qrCode;
    if (data == null) return null;
    final comma = data.indexOf(',');
    return base64Decode(comma >= 0 ? data.substring(comma + 1) : data);
  }

  /// Explicação do motivo da desconexão para exibir ao usuário.
  String? get reasonMessage {
    switch (reason) {
      case 'LOGGED_OUT':
        return 'O aparelho foi desconectado pelo celular. Conecte de novo '
            'lendo o QR code.';
      case 'QR_TIMEOUT':
        return 'O QR code expirou sem leitura. Gere um novo.';
      case 'CONNECTION_LOST':
        return 'A conexão caiu por um instante; reconectando sozinho.';
      case 'GATEWAY_UNAVAILABLE':
        return 'O serviço de WhatsApp do Olie não está respondendo.';
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [status, qrCode, phone, reason];
}
