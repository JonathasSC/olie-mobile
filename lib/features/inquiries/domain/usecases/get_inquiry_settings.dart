import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

class GetInquirySettings implements UseCase<InquirySettings, NoParams> {
  final InquiryRepository repository;

  GetInquirySettings(this.repository);

  @override
  Future<Either<Failure, InquirySettings>> call(NoParams params) {
    return repository.getSettings();
  }
}
