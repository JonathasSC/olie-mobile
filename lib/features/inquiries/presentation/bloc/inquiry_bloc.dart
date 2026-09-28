import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/usecases/cancel_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiries.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';
import 'package:olie/features/inquiries/domain/usecases/pause_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resend_failed_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resume_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/watch_inquiry_events.dart';

part 'inquiry_event.dart';
part 'inquiry_state.dart';

/// Histórico de consultas, detalhe de cada uma e o acompanhamento em tempo
/// real: cada evento do WebSocket atualiza a lista e o detalhe aberto.
class InquiryBloc extends Bloc<InquiryBlocEvent, InquiryState> {
  final GetInquiries getInquiries;
  final GetInquiry getInquiry;
  final PauseInquiry pauseInquiry;
  final ResumeInquiry resumeInquiry;
  final CancelInquiry cancelInquiry;
  final ResendFailedInquiry resendFailedInquiry;
  final WatchInquiryEvents watchInquiryEvents;

  InquiryBloc({
    required this.getInquiries,
    required this.getInquiry,
    required this.pauseInquiry,
    required this.resumeInquiry,
    required this.cancelInquiry,
    required this.resendFailedInquiry,
    required this.watchInquiryEvents,
  }) : super(const InquiryState()) {
    on<InquiriesRequested>(_onInquiriesRequested);
    on<InquiryRealtimeStarted>(
      _onRealtimeStarted,
      transformer: (events, mapper) => events.take(1).asyncExpand(mapper),
    );
    on<InquiryDetailRequested>(_onDetailRequested);
    on<InquiryCreated>((event, emit) => emit(_upsert(event.inquiry)));
    on<InquiryPauseRequested>(
      (event, emit) => _control(emit, pauseInquiry(InquiryIdParams(event.id))),
    );
    on<InquiryResumeRequested>(
      (event, emit) => _control(emit, resumeInquiry(InquiryIdParams(event.id))),
    );
    on<InquiryCancelRequested>(
      (event, emit) => _control(emit, cancelInquiry(InquiryIdParams(event.id))),
    );
    on<InquiryResendFailedRequested>(
      (event, emit) =>
          _control(emit, resendFailedInquiry(InquiryIdParams(event.id))),
    );
  }

  Future<void> _onInquiriesRequested(
    InquiriesRequested event,
    Emitter<InquiryState> emit,
  ) async {
    final filter = event.filter ?? state.filter;
    emit(state.copyWith(status: InquiryStatusView.loading, filter: filter));

    final result = await getInquiries(filter);
    result.fold(
      (failure) => _fail(emit, failure),
      (inquiries) => emit(state.copyWith(
        status: InquiryStatusView.success,
        inquiries: inquiries,
      )),
    );
  }

  Future<void> _onRealtimeStarted(
    InquiryRealtimeStarted event,
    Emitter<InquiryState> emit,
  ) async {
    await emit.forEach<InquiryEvent>(
      watchInquiryEvents(),
      onData: _applyEvent,
    );
  }

  Future<void> _onDetailRequested(
    InquiryDetailRequested event,
    Emitter<InquiryState> emit,
  ) async {
    final result = await getInquiry(InquiryIdParams(event.id));
    result.fold(
      (failure) => _fail(emit, failure),
      (inquiry) => emit(_upsert(inquiry)),
    );
  }

  Future<void> _control(
    Emitter<InquiryState> emit,
    Future<Either<Failure, Inquiry>> request,
  ) async {
    final result = await request;
    result.fold(
      (failure) => _fail(emit, failure),
      (inquiry) => emit(_upsert(inquiry)),
    );
  }

  InquiryState _applyEvent(InquiryEvent event) {
    final detail = state.details[event.inquiryId];
    return state.copyWith(
      inquiries: [
        for (final inquiry in state.inquiries)
          inquiry.id == event.inquiryId ? inquiry.apply(event) : inquiry,
      ],
      details: detail == null
          ? state.details
          : {...state.details, event.inquiryId: detail.apply(event)},
      lastFinished: event.type == InquiryEventType.inquiryFinished
          ? event
          : null,
    );
  }

  /// Guarda a versão completa no detalhe e atualiza (ou insere no topo) o
  /// item do histórico.
  InquiryState _upsert(Inquiry inquiry) {
    final exists = state.inquiries.any((current) => current.id == inquiry.id);
    return state.copyWith(
      status: InquiryStatusView.success,
      inquiries: exists
          ? [
              for (final current in state.inquiries)
                current.id == inquiry.id ? inquiry : current,
            ]
          : [inquiry, ...state.inquiries],
      details: {...state.details, inquiry.id: inquiry},
    );
  }

  void _fail(Emitter<InquiryState> emit, Failure failure) {
    emit(state.copyWith(
      status: InquiryStatusView.failure,
      errorMessage: failure.message,
    ));
  }
}
