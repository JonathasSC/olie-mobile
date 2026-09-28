import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';

class InquiryModel extends Inquiry {
  const InquiryModel({
    required super.id,
    required super.status,
    super.pauseReason,
    required super.simulated,
    super.categoryIds,
    required super.items,
    super.recipients,
    required super.totals,
    super.nextSendAt,
    required super.startedAt,
    super.finishedAt,
    required super.createdAt,
  });

  /// Serve para o detalhe (`InquiryResponse`) e para o histórico
  /// (`InquirySummaryResponse`, sem `recipients`).
  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['id'] as String,
      status: InquiryStatus.fromApiValue(json['status'] as String),
      pauseReason: InquiryPauseReason.fromApiValue(
        json['pauseReason'] as String?,
      ),
      simulated: json['simulated'] as bool,
      categoryIds: (json['categoryIds'] as List<dynamic>? ?? const [])
          .cast<String>(),
      items: (json['items'] as List<dynamic>)
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(),
      recipients: (json['recipients'] as List<dynamic>? ?? const [])
          .map((r) => recipientFromJson(r as Map<String, dynamic>))
          .toList(),
      totals: totalsFromJson(json['totals'] as Map<String, dynamic>),
      nextSendAt: _parseInstant(json['nextSendAt']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: _parseInstant(json['finishedAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static InquiryItem itemFromJson(Map<String, dynamic> json) {
    return InquiryItem(
      id: json['id'] as String,
      position: (json['position'] as num).toInt(),
      name: json['name'] as String,
      photoId: json['photoId'] as String?,
    );
  }

  static InquiryRecipient recipientFromJson(Map<String, dynamic> json) {
    return InquiryRecipient(
      id: json['id'] as String,
      contactId: json['contactId'] as String?,
      contactName: json['contactName'] as String,
      phone: json['phone'] as String,
      status: InquiryRecipientStatus.fromApiValue(json['status'] as String),
      failureReason: json['failureReason'] as String?,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      sentAt: _parseInstant(json['sentAt']),
      messageText: json['messageText'] as String?,
    );
  }

  static InquiryTotals totalsFromJson(Map<String, dynamic> json) {
    int value(String key) => (json[key] as num?)?.toInt() ?? 0;
    return InquiryTotals(
      total: value('total'),
      pending: value('pending'),
      sending: value('sending'),
      sent: value('sent'),
      failed: value('failed'),
      cancelled: value('cancelled'),
    );
  }

  static InquiryEvent eventFromJson(Map<String, dynamic> json) {
    final recipient = json['recipient'] as Map<String, dynamic>?;
    return InquiryEvent(
      type: InquiryEventType.fromApiValue(json['type'] as String),
      inquiryId: json['inquiryId'] as String,
      status: InquiryStatus.fromApiValue(json['status'] as String),
      pauseReason: InquiryPauseReason.fromApiValue(
        json['pauseReason'] as String?,
      ),
      simulated: json['simulated'] as bool? ?? false,
      nextSendAt: _parseInstant(json['nextSendAt']),
      totals: totalsFromJson(json['totals'] as Map<String, dynamic>),
      recipient: recipient == null ? null : recipientFromJson(recipient),
    );
  }

  static DateTime? _parseInstant(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
