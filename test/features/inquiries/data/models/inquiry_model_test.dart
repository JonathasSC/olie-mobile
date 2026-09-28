import 'package:flutter_test/flutter_test.dart';

import 'package:olie/features/inquiries/data/models/inquiry_model.dart';
import 'package:olie/features/inquiries/data/models/inquiry_support_model.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';

/// Formatos copiados de respostas reais da API.
Map<String, dynamic> inquiryJson() => {
  'id': 'q1',
  'status': 'SENDING',
  'pauseReason': null,
  'simulated': false,
  'categoryIds': ['c1'],
  'items': [
    {
      'id': 'i1',
      'position': 0,
      'name': 'Dipirona 500mg',
      'photoId': 'p1',
      'photoUrl': '/api/v1/inquiry-photos/p1',
    },
  ],
  'recipients': [
    {
      'id': 'r1',
      'contactId': 'k1',
      'contactName': 'Farmácia Boa',
      'phone': '+5511922222222',
      'status': 'PENDING',
      'failureReason': null,
      'attempts': 0,
      'sentAt': null,
      'messageText': null,
    },
    {
      'id': 'r2',
      'contactId': null,
      'contactName': 'Mercado Sol',
      'phone': '+5511933333333',
      'status': 'SENT',
      'failureReason': null,
      'attempts': 1,
      'sentAt': '2026-09-28T12:43:46.123Z',
      'messageText': 'Bom dia! Tem esse item?\n\n1. Dipirona 500mg',
    },
  ],
  'totals': {
    'total': 2,
    'pending': 1,
    'sending': 0,
    'sent': 1,
    'failed': 0,
    'cancelled': 0,
  },
  'nextSendAt': '2026-09-28T12:44:21Z',
  'startedAt': '2026-09-28T12:43:45Z',
  'finishedAt': null,
  'createdAt': '2026-09-28T12:43:45Z',
};

void main() {
  test('lê o detalhe da consulta', () {
    final inquiry = InquiryModel.fromJson(inquiryJson());

    expect(inquiry.status, InquiryStatus.sending);
    expect(inquiry.items.single.photoId, 'p1');
    expect(inquiry.recipients, hasLength(2));
    expect(inquiry.recipients[1].contactId, isNull);
    expect(inquiry.recipients[1].status, InquiryRecipientStatus.sent);
    expect(inquiry.totals.done, 1);
    expect(inquiry.nextSendAt, DateTime.utc(2026, 9, 28, 12, 44, 21));
    expect(inquiry.canPause, isTrue);
    expect(inquiry.canResendFailed, isFalse);
  });

  test('lê o resumo do histórico (sem recipients)', () {
    final json = inquiryJson()..remove('recipients');

    expect(InquiryModel.fromJson(json).recipients, isEmpty);
  });

  test('aplica um evento de contato em tempo real', () {
    final inquiry = InquiryModel.fromJson(inquiryJson());
    final event = InquiryModel.eventFromJson({
      'type': 'RECIPIENT_UPDATED',
      'inquiryId': 'q1',
      'status': 'SENDING',
      'pauseReason': null,
      'simulated': false,
      'nextSendAt': null,
      'totals': {'total': 2, 'pending': 0, 'sending': 1, 'sent': 1},
      'recipient': {
        'id': 'r1',
        'contactId': 'k1',
        'contactName': 'Farmácia Boa',
        'phone': '+5511922222222',
        'status': 'SENDING',
        'attempts': 0,
      },
    });

    final updated = inquiry.apply(event);

    expect(event.type, InquiryEventType.recipientUpdated);
    expect(updated.recipients.first.status, InquiryRecipientStatus.sending);
    expect(updated.recipients[1], inquiry.recipients[1]);
    expect(updated.totals.sending, 1);
    expect(updated.nextSendAt, isNull);
  });

  test('evento de pausa por queda de conexão', () {
    final inquiry = InquiryModel.fromJson(inquiryJson());
    final event = InquiryModel.eventFromJson({
      'type': 'INQUIRY_UPDATED',
      'inquiryId': 'q1',
      'status': 'PAUSED',
      'pauseReason': 'CONNECTION_LOST',
      'simulated': false,
      'nextSendAt': null,
      'totals': inquiryJson()['totals'],
      'recipient': null,
    });

    final updated = inquiry.apply(event);

    expect(updated.status, InquiryStatus.paused);
    expect(updated.pauseReason, InquiryPauseReason.connectionLost);
    expect(updated.canResume, isTrue);
  });

  test('lê os avisos de consulta repetida', () {
    final warnings = InquirySupportModel.warningsFromJson([
      {
        'contactId': 'k1',
        'contactName': 'Mercado Sol',
        'itemName': 'Luva nitrílica',
        'sentAt': '2026-09-28T12:43:46Z',
      },
    ]);

    expect(warnings.single.itemName, 'Luva nitrílica');
  });

  test('lê o rascunho para repetir a consulta', () {
    final draft = InquirySupportModel.draftFromJson({
      'categoryIds': ['c1'],
      'contactIds': ['k1', 'k2'],
      'items': [
        {'name': 'Dipirona 500mg', 'photoId': 'p1'},
        {'name': 'Soro', 'photoId': null},
      ],
      'skippedContacts': [
        {'contactName': 'Antiga', 'reason': 'Contato removido'},
      ],
    });

    expect(draft.categoryIds, {'c1'});
    expect(draft.items[1].photoId, isNull);
    expect(draft.skippedContacts.single.reason, 'Contato removido');
  });
}
