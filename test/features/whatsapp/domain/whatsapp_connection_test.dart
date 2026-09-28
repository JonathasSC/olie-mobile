import 'package:flutter_test/flutter_test.dart';

import 'package:olie/features/whatsapp/data/models/whatsapp_connection_model.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';

void main() {
  test('decodifica o QR code em data URL', () {
    final connection = WhatsAppConnectionModel.fromJson({
      'status': 'WAITING_QR',
      // PNG de 1x1 em data URL (mesmo formato enviado pelo gateway).
      'qrCode':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
          'AAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      'phone': null,
      'reason': null,
      'connected': false,
    });

    expect(connection.status, WhatsAppConnectionStatus.waitingQr);
    expect(connection.qrCodeBytes!.sublist(1, 4), 'PNG'.codeUnits);
    expect(connection.isConnected, isFalse);
  });

  test('explica o motivo da desconexão', () {
    const connection = WhatsAppConnection(
      status: WhatsAppConnectionStatus.disconnected,
      reason: 'LOGGED_OUT',
    );

    expect(connection.reasonMessage, contains('desconectado pelo celular'));
  });
}
