import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';

class WhatsAppConnectionModel extends WhatsAppConnection {
  const WhatsAppConnectionModel({
    required super.status,
    super.qrCode,
    super.phone,
    super.reason,
  });

  factory WhatsAppConnectionModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppConnectionModel(
      status: WhatsAppConnectionStatus.fromApiValue(json['status'] as String),
      qrCode: json['qrCode'] as String?,
      phone: json['phone'] as String?,
      reason: json['reason'] as String?,
    );
  }
}
