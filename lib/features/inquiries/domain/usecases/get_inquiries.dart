import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

/// Histórico, mais recentes primeiro.
class GetInquiries implements UseCase<List<Inquiry>, InquiryFilter> {
  final InquiryRepository repository;

  GetInquiries(this.repository);

  @override
  Future<Either<Failure, List<Inquiry>>> call(InquiryFilter params) {
    return repository.getInquiries(params);
  }
}
