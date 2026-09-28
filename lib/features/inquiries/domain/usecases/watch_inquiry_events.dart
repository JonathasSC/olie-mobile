import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

/// Não implementa [UseCase] pois expõe um [Stream] contínuo.
class WatchInquiryEvents {
  final InquiryRepository repository;

  WatchInquiryEvents(this.repository);

  Stream<InquiryEvent> call() => repository.watchEvents();
}
