enum InquiryStatus {
  sending,
  paused,
  completed,
  cancelled;

  static InquiryStatus fromApiValue(String value) {
    switch (value) {
      case 'SENDING':
        return InquiryStatus.sending;
      case 'PAUSED':
        return InquiryStatus.paused;
      case 'COMPLETED':
        return InquiryStatus.completed;
      case 'CANCELLED':
        return InquiryStatus.cancelled;
      default:
        throw ArgumentError('Status de consulta desconhecido: $value');
    }
  }

  String get label {
    switch (this) {
      case InquiryStatus.sending:
        return 'Enviando';
      case InquiryStatus.paused:
        return 'Pausada';
      case InquiryStatus.completed:
        return 'Concluída';
      case InquiryStatus.cancelled:
        return 'Cancelada';
    }
  }

}

enum InquiryPauseReason {
  user,
  connectionLost;

  static InquiryPauseReason? fromApiValue(String? value) {
    switch (value) {
      case 'USER':
        return InquiryPauseReason.user;
      case 'CONNECTION_LOST':
        return InquiryPauseReason.connectionLost;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case InquiryPauseReason.user:
        return 'Pausada por você';
      case InquiryPauseReason.connectionLost:
        return 'O WhatsApp caiu no meio do envio. Reconecte e retome.';
    }
  }
}

enum InquiryRecipientStatus {
  pending,
  sending,
  sent,
  failed,
  cancelled;

  static InquiryRecipientStatus fromApiValue(String value) {
    switch (value) {
      case 'PENDING':
        return InquiryRecipientStatus.pending;
      case 'SENDING':
        return InquiryRecipientStatus.sending;
      case 'SENT':
        return InquiryRecipientStatus.sent;
      case 'FAILED':
        return InquiryRecipientStatus.failed;
      case 'CANCELLED':
        return InquiryRecipientStatus.cancelled;
      default:
        throw ArgumentError('Status de destinatário desconhecido: $value');
    }
  }

  String get label {
    switch (this) {
      case InquiryRecipientStatus.pending:
        return 'Aguardando';
      case InquiryRecipientStatus.sending:
        return 'Enviando';
      case InquiryRecipientStatus.sent:
        return 'Enviado';
      case InquiryRecipientStatus.failed:
        return 'Falhou';
      case InquiryRecipientStatus.cancelled:
        return 'Cancelado';
    }
  }

}
