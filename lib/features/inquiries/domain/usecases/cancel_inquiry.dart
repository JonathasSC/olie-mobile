import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';

/// Cancela quem ainda está na fila.
class CancelInquiry implements UseCase<Inquiry, InquiryIdParams> {
  final InquiryRepository repository;

  CancelInquiry(this.repository);

  @override
  Future<Either<Failure, Inquiry>> call(InquiryIdParams params) {
    return repository.cancel(params.id);
  }
}
