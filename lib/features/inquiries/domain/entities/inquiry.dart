import 'package:equatable/equatable.dart';

import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';

class InquiryItem extends Equatable {
  final String id;
  final int position;
  final String name;
  final String? photoId;

  const InquiryItem({
    required this.id,
    required this.position,
    required this.name,
    this.photoId,
  });

  @override
  List<Object?> get props => [id, position, name, photoId];
}

class InquiryRecipient extends Equatable {
  final String id;

  /// `null` se o contato foi removido depois (nome e telefone são cópias).
  final String? contactId;
  final String contactName;
  final String phone;
  final InquiryRecipientStatus status;
  final String? failureReason;
  final int attempts;
  final DateTime? sentAt;

  /// Texto que o contato recebeu (ou receberia, na simulação).
  final String? messageText;

  const InquiryRecipient({
    required this.id,
    this.contactId,
    required this.contactName,
    required this.phone,
    required this.status,
    this.failureReason,
    this.attempts = 0,
    this.sentAt,
    this.messageText,
  });

  @override
  List<Object?> get props => [
    id,
    contactId,
    contactName,
    phone,
    status,
    failureReason,
    attempts,
    sentAt,
    messageText,
  ];
}

class InquiryTotals extends Equatable {
  final int total;
  final int pending;
  final int sending;
  final int sent;
  final int failed;
  final int cancelled;

  const InquiryTotals({
    this.total = 0,
    this.pending = 0,
    this.sending = 0,
    this.sent = 0,
    this.failed = 0,
    this.cancelled = 0,
  });

  /// Contatos já resolvidos (enviados, com falha ou cancelados).
  int get done => sent + failed + cancelled;

  @override
  List<Object?> get props => [total, pending, sending, sent, failed, cancelled];
}

class Inquiry extends Equatable {
  final String id;
  final InquiryStatus status;
  final InquiryPauseReason? pauseReason;
  final bool simulated;
  final List<String> categoryIds;
  final List<InquiryItem> items;

  /// Vazio no histórico (resumo); preenchido no detalhe.
  final List<InquiryRecipient> recipients;
  final InquiryTotals totals;

  /// Quando o próximo contato será processado — base da contagem regressiva.
  final DateTime? nextSendAt;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;

  const Inquiry({
    required this.id,
    required this.status,
    this.pauseReason,
    required this.simulated,
    this.categoryIds = const [],
    required this.items,
    this.recipients = const [],
    required this.totals,
    this.nextSendAt,
    required this.startedAt,
    this.finishedAt,
    required this.createdAt,
  });

  bool get canPause => status == InquiryStatus.sending;

  bool get canResume => status == InquiryStatus.paused;

  bool get canCancel =>
      status == InquiryStatus.sending || status == InquiryStatus.paused;

  bool get canResendFailed => totals.failed > 0 && status != InquiryStatus.sending;

  bool get isFinished =>
      status == InquiryStatus.completed || status == InquiryStatus.cancelled;

  /// Aplica um evento recebido em tempo real (status, contagens, próximo
  /// envio e, quando vier, o contato que mudou).
  Inquiry apply(InquiryEvent event) {
    final recipient = event.recipient;
    return Inquiry(
      id: id,
      status: event.status,
      pauseReason: event.pauseReason,
      simulated: simulated,
      categoryIds: categoryIds,
      items: items,
      recipients: recipient == null
          ? recipients
          : [
              for (final current in recipients)
                current.id == recipient.id ? recipient : current,
            ],
      totals: event.totals,
      nextSendAt: event.nextSendAt,
      startedAt: startedAt,
      finishedAt: event.type == InquiryEventType.inquiryFinished
          ? (finishedAt ?? DateTime.now())
          : finishedAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    pauseReason,
    simulated,
    categoryIds,
    items,
    recipients,
    totals,
    nextSendAt,
    startedAt,
    finishedAt,
    createdAt,
  ];
}
