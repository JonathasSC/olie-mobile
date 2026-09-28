import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';

/// Bytes da foto (a rota exige autenticação, então não dá para usar
/// `Image.network` direto).
class GetInquiryPhoto implements UseCase<Uint8List, InquiryIdParams> {
  final InquiryRepository repository;

  GetInquiryPhoto(this.repository);

  @override
  Future<Either<Failure, Uint8List>> call(InquiryIdParams params) {
    return repository.getPhoto(params.id);
  }
}
