import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';

/// Retoma o envio (exige WhatsApp conectado, exceto simulação).
class ResumeInquiry implements UseCase<Inquiry, InquiryIdParams> {
  final InquiryRepository repository;

  ResumeInquiry(this.repository);

  @override
  Future<Either<Failure, Inquiry>> call(InquiryIdParams params) {
    return repository.resume(params.id);
  }
}
