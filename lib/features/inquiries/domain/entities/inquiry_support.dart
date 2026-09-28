import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';

/// Limites e modelo da mensagem definidos no backend.
class InquirySettings extends Equatable {
  final String messageTemplate;
  final String timezone;
  final int maxItems;
  final int maxRecipients;
  final int contactIntervalMinSeconds;
  final int contactIntervalMaxSeconds;
  final int duplicateWindowHours;
  final int maxPhotoUploadBytes;

  const InquirySettings({
    required this.messageTemplate,
    required this.timezone,
    required this.maxItems,
    required this.maxRecipients,
    required this.contactIntervalMinSeconds,
    required this.contactIntervalMaxSeconds,
    required this.duplicateWindowHours,
    required this.maxPhotoUploadBytes,
  });

  @override
  List<Object?> get props => [
    messageTemplate,
    timezone,
    maxItems,
    maxRecipients,
    contactIntervalMinSeconds,
    contactIntervalMaxSeconds,
    duplicateWindowHours,
    maxPhotoUploadBytes,
  ];
}

/// Item como enviado na criação (e devolvido pelo rascunho de repetição).
class InquiryItemDraft extends Equatable {
  final String name;
  final String? photoId;

  const InquiryItemDraft({required this.name, this.photoId});

  @override
  List<Object?> get props => [name, photoId];
}

class SkippedContact extends Equatable {
  final String contactName;
  final String reason;

  const SkippedContact({required this.contactName, required this.reason});

  @override
  List<Object?> get props => [contactName, reason];
}

/// Consulta anterior no formato da criação, para "repetir consulta".
class InquiryDraft extends Equatable {
  final Set<String> categoryIds;
  final List<String> contactIds;
  final List<InquiryItemDraft> items;

  /// Contatos que não podem mais receber (removidos, inativos...).
  final List<SkippedContact> skippedContacts;

  const InquiryDraft({
    required this.categoryIds,
    required this.contactIds,
    required this.items,
    this.skippedContacts = const [],
  });

  @override
  List<Object?> get props => [categoryIds, contactIds, items, skippedContacts];
}

class InquiryPhoto extends Equatable {
  final String id;
  final String contentType;
  final int sizeBytes;
  final int width;
  final int height;

  const InquiryPhoto({
    required this.id,
    required this.contentType,
    required this.sizeBytes,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [id, contentType, sizeBytes, width, height];
}

enum PreviewMessageType { text, photo }

class PreviewMessage extends Equatable {
  final PreviewMessageType type;
  final String text;
  final String? photoId;

  const PreviewMessage({required this.type, required this.text, this.photoId});

  @override
  List<Object?> get props => [type, text, photoId];
}

/// Sequência exata de mensagens que cada contato vai receber.
class InquiryPreview extends Equatable {
  final String greeting;
  final String question;
  final List<PreviewMessage> messages;

  const InquiryPreview({
    required this.greeting,
    required this.question,
    required this.messages,
  });

  @override
  List<Object?> get props => [greeting, question, messages];
}

class DuplicateInquiryWarning extends Equatable {
  final String contactId;
  final String contactName;
  final String itemName;
  final DateTime sentAt;

  const DuplicateInquiryWarning({
    required this.contactId,
    required this.contactName,
    required this.itemName,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [contactId, contactName, itemName, sentAt];
}

/// Alguns contatos já receberam estes itens recentemente: é preciso
/// confirmar para enviar de novo.
class DuplicateInquiryFailure extends Failure {
  final List<DuplicateInquiryWarning> warnings;

  const DuplicateInquiryFailure(super.message, this.warnings);

  @override
  List<Object?> get props => [message, warnings];
}

class InquiryFilter extends Equatable {
  final DateTime? from;
  final DateTime? to;
  final String? categoryId;
  final String? item;
  final bool? simulated;

  const InquiryFilter({
    this.from,
    this.to,
    this.categoryId,
    this.item,
    this.simulated,
  });

  bool get isEmpty =>
      from == null &&
      to == null &&
      categoryId == null &&
      (item == null || item!.isEmpty) &&
      simulated == null;

  @override
  List<Object?> get props => [from, to, categoryId, item, simulated];
}
