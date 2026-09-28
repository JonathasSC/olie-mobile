import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';

extension InquiryStatusTone on InquiryStatus {
  Tone get tone => switch (this) {
    InquiryStatus.sending => Tone.calm,
    InquiryStatus.paused => Tone.warning,
    InquiryStatus.completed => Tone.money,
    InquiryStatus.cancelled => Tone.muted,
  };
}

extension InquiryRecipientStatusTone on InquiryRecipientStatus {
  Tone get tone => switch (this) {
    InquiryRecipientStatus.pending => Tone.muted,
    InquiryRecipientStatus.sending => Tone.warning,
    InquiryRecipientStatus.sent => Tone.calm,
    InquiryRecipientStatus.failed => Tone.critical,
    InquiryRecipientStatus.cancelled => Tone.muted,
  };
}
