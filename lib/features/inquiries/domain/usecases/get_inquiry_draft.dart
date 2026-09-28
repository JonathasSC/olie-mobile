import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';

/// Dados de uma consulta anterior para abrir o formulário já preenchido.
class GetInquiryDraft implements UseCase<InquiryDraft, InquiryIdParams> {
  final InquiryRepository repository;

  GetInquiryDraft(this.repository);

  @override
  Future<Either<Failure, InquiryDraft>> call(InquiryIdParams params) {
    return repository.getDraft(params.id);
  }
}
