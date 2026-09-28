part of 'inquiry_bloc.dart';

/// Eventos do bloc (o nome `InquiryEvent` já é o evento do WebSocket).
abstract class InquiryBlocEvent extends Equatable {
  const InquiryBlocEvent();

  @override
  List<Object?> get props => [];
}

class InquiriesRequested extends InquiryBlocEvent {
  /// Novo filtro; `null` mantém o atual.
  final InquiryFilter? filter;

  const InquiriesRequested({this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Passa a aplicar os eventos de `/user/queue/inquiries`.
class InquiryRealtimeStarted extends InquiryBlocEvent {
  const InquiryRealtimeStarted();
}

class InquiryDetailRequested extends InquiryBlocEvent {
  final String id;

  const InquiryDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Consulta recém-criada pelo formulário.
class InquiryCreated extends InquiryBlocEvent {
  final Inquiry inquiry;

  const InquiryCreated(this.inquiry);

  @override
  List<Object?> get props => [inquiry];
}

class InquiryPauseRequested extends InquiryBlocEvent {
  final String id;

  const InquiryPauseRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class InquiryResumeRequested extends InquiryBlocEvent {
  final String id;

  const InquiryResumeRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class InquiryCancelRequested extends InquiryBlocEvent {
  final String id;

  const InquiryCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class InquiryResendFailedRequested extends InquiryBlocEvent {
  final String id;

  const InquiryResendFailedRequested(this.id);

  @override
  List<Object?> get props => [id];
}
