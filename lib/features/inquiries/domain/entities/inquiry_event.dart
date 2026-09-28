import 'package:equatable/equatable.dart';

import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';

enum InquiryEventType {
  /// Um contato mudou de status.
  recipientUpdated,

  /// Pausa, retomada, cancelamento ou próximo envio agendado.
  inquiryUpdated,

  /// Terminou: `totals` é o resumo final.
  inquiryFinished;

  static InquiryEventType fromApiValue(String value) {
    switch (value) {
      case 'RECIPIENT_UPDATED':
        return InquiryEventType.recipientUpdated;
      case 'INQUIRY_UPDATED':
        return InquiryEventType.inquiryUpdated;
      case 'INQUIRY_FINISHED':
        return InquiryEventType.inquiryFinished;
      default:
        throw ArgumentError('Evento de consulta desconhecido: $value');
    }
  }
}

/// Progresso de uma consulta, recebido em `/user/queue/inquiries`.
class InquiryEvent extends Equatable {
  final InquiryEventType type;
  final String inquiryId;
  final InquiryStatus status;
  final InquiryPauseReason? pauseReason;
  final bool simulated;
  final DateTime? nextSendAt;
  final InquiryTotals totals;
  final InquiryRecipient? recipient;

  const InquiryEvent({
    required this.type,
    required this.inquiryId,
    required this.status,
    this.pauseReason,
    required this.simulated,
    this.nextSendAt,
    required this.totals,
    this.recipient,
  });

  @override
  List<Object?> get props => [
    type,
    inquiryId,
    status,
    pauseReason,
    simulated,
    nextSendAt,
    totals,
    recipient,
  ];
}
