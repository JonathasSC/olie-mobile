part of 'inquiry_bloc.dart';

/// `InquiryStatus` já é o status da consulta no domínio.
enum InquiryStatusView { initial, loading, success, failure }

class InquiryState extends Equatable {
  final InquiryStatusView status;
  final List<Inquiry> inquiries;
  final InquiryFilter filter;

  /// Consultas carregadas por completo (com destinatários), por id.
  final Map<String, Inquiry> details;
  final String? errorMessage;

  /// Última consulta que terminou, para avisar com o resumo.
  final InquiryEvent? lastFinished;

  const InquiryState({
    this.status = InquiryStatusView.initial,
    this.inquiries = const [],
    this.filter = const InquiryFilter(),
    this.details = const {},
    this.errorMessage,
    this.lastFinished,
  });

  InquiryState copyWith({
    InquiryStatusView? status,
    List<Inquiry>? inquiries,
    InquiryFilter? filter,
    Map<String, Inquiry>? details,
    String? errorMessage,
    InquiryEvent? lastFinished,
  }) {
    return InquiryState(
      status: status ?? this.status,
      inquiries: inquiries ?? this.inquiries,
      filter: filter ?? this.filter,
      details: details ?? this.details,
      errorMessage: errorMessage,
      lastFinished: lastFinished,
    );
  }

  @override
  List<Object?> get props => [
    status,
    inquiries,
    filter,
    details,
    errorMessage,
    lastFinished,
  ];
}
