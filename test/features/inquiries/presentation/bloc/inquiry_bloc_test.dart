import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/usecases/cancel_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiries.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';
import 'package:olie/features/inquiries/domain/usecases/pause_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resend_failed_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resume_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/watch_inquiry_events.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';

class MockGetInquiries extends Mock implements GetInquiries {}

class MockGetInquiry extends Mock implements GetInquiry {}

class MockPauseInquiry extends Mock implements PauseInquiry {}

class MockResumeInquiry extends Mock implements ResumeInquiry {}

class MockCancelInquiry extends Mock implements CancelInquiry {}

class MockResendFailedInquiry extends Mock implements ResendFailedInquiry {}

class MockWatchInquiryEvents extends Mock implements WatchInquiryEvents {}

Inquiry inquiry({
  InquiryStatus status = InquiryStatus.sending,
  List<InquiryRecipient> recipients = const [],
}) => Inquiry(
  id: 'q1',
  status: status,
  simulated: false,
  items: const [InquiryItem(id: 'i1', position: 0, name: 'Dipirona')],
  recipients: recipients,
  totals: const InquiryTotals(total: 1, pending: 1),
  startedAt: DateTime.utc(2026, 9, 28),
  createdAt: DateTime.utc(2026, 9, 28),
);

void main() {
  late MockGetInquiries getInquiries;
  late MockGetInquiry getInquiry;
  late MockPauseInquiry pause;
  late MockWatchInquiryEvents watch;
  late StreamController<InquiryEvent> events;

  const pending = InquiryRecipient(
    id: 'r1',
    contactName: 'Farmácia',
    phone: '+5511999999999',
    status: InquiryRecipientStatus.pending,
  );

  setUpAll(() {
    registerFallbackValue(const InquiryFilter());
    registerFallbackValue(const InquiryIdParams('x'));
  });

  setUp(() {
    getInquiries = MockGetInquiries();
    getInquiry = MockGetInquiry();
    pause = MockPauseInquiry();
    watch = MockWatchInquiryEvents();
    events = StreamController<InquiryEvent>.broadcast();
    when(() => watch()).thenAnswer((_) => events.stream);
  });

  tearDown(() async {
    if (!events.isClosed) await events.close();
  });

  InquiryBloc build() => InquiryBloc(
    getInquiries: getInquiries,
    getInquiry: getInquiry,
    pauseInquiry: pause,
    resumeInquiry: MockResumeInquiry(),
    cancelInquiry: MockCancelInquiry(),
    resendFailedInquiry: MockResendFailedInquiry(),
    watchInquiryEvents: watch,
  );

  blocTest<InquiryBloc, InquiryState>(
    'eventos em tempo real atualizam o histórico e o detalhe aberto',
    build: () {
      when(() => getInquiry(any())).thenAnswer(
        (_) async => Right(inquiry(recipients: const [pending])),
      );
      return build();
    },
    act: (bloc) async {
      bloc
        ..add(const InquiryRealtimeStarted())
        ..add(const InquiryDetailRequested('q1'));
      await Future<void>.delayed(Duration.zero);
      events.add(
        const InquiryEvent(
          type: InquiryEventType.recipientUpdated,
          inquiryId: 'q1',
          status: InquiryStatus.sending,
          simulated: false,
          totals: InquiryTotals(total: 1, sent: 1),
          recipient: InquiryRecipient(
            id: 'r1',
            contactName: 'Farmácia',
            phone: '+5511999999999',
            status: InquiryRecipientStatus.sent,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      // Encerra a escuta, senão o blocTest espera o stream para sempre.
      await events.close();
    },
    verify: (bloc) {
      final detail = bloc.state.details['q1']!;
      expect(detail.recipients.single.status, InquiryRecipientStatus.sent);
      expect(bloc.state.inquiries.single.totals.sent, 1);
    },
  );

  blocTest<InquiryBloc, InquiryState>(
    'fim da consulta fica disponível para o aviso de resumo',
    build: () {
      when(() => getInquiry(any())).thenAnswer((_) async => Right(inquiry()));
      return build();
    },
    act: (bloc) async {
      bloc
        ..add(const InquiryRealtimeStarted())
        ..add(const InquiryDetailRequested('q1'));
      await Future<void>.delayed(Duration.zero);
      events.add(
        const InquiryEvent(
          type: InquiryEventType.inquiryFinished,
          inquiryId: 'q1',
          status: InquiryStatus.completed,
          simulated: false,
          totals: InquiryTotals(total: 1, sent: 1),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      // Encerra a escuta, senão o blocTest espera o stream para sempre.
      await events.close();
    },
    verify: (bloc) {
      expect(bloc.state.lastFinished?.totals.sent, 1);
      expect(bloc.state.details['q1']!.isFinished, isTrue);
    },
  );

  blocTest<InquiryBloc, InquiryState>(
    'pausar substitui a consulta pelo retorno da API',
    build: () {
      when(() => pause(any())).thenAnswer(
        (_) async => Right(inquiry(status: InquiryStatus.paused)),
      );
      return build();
    },
    seed: () => InquiryState(inquiries: [inquiry()]),
    act: (bloc) => bloc.add(const InquiryPauseRequested('q1')),
    verify: (bloc) {
      expect(bloc.state.inquiries.single.status, InquiryStatus.paused);
      expect(bloc.state.details['q1']!.canResume, isTrue);
    },
  );
}
