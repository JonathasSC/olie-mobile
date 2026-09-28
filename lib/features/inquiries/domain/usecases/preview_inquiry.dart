import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

/// Pré-visualização oficial do backend, usada na confirmação do envio.
class PreviewInquiry implements UseCase<InquiryPreview, PreviewInquiryParams> {
  final InquiryRepository repository;

  PreviewInquiry(this.repository);

  @override
  Future<Either<Failure, InquiryPreview>> call(PreviewInquiryParams params) {
    return repository.preview(params.items);
  }
}

class PreviewInquiryParams extends Equatable {
  final List<InquiryItemDraft> items;

  const PreviewInquiryParams(this.items);

  @override
  List<Object?> get props => [items];
}
