import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

/// Envia a foto de um item antes de criar a consulta; o backend reduz,
/// corrige a rotação e converte para JPEG quando preciso.
class UploadInquiryPhoto
    implements UseCase<InquiryPhoto, UploadInquiryPhotoParams> {
  final InquiryRepository repository;

  UploadInquiryPhoto(this.repository);

  @override
  Future<Either<Failure, InquiryPhoto>> call(
    UploadInquiryPhotoParams params,
  ) async {
    final maxBytes = params.maxBytes;
    if (maxBytes != null && params.bytes.length > maxBytes) {
      final megabytes = (maxBytes / (1024 * 1024)).round();
      return Left(
        ValidationFailure('A imagem passa do limite de $megabytes MB.'),
      );
    }
    return repository.uploadPhoto(
      bytes: params.bytes,
      fileName: params.fileName,
    );
  }
}

class UploadInquiryPhotoParams extends Equatable {
  final Uint8List bytes;
  final String fileName;
  final int? maxBytes;

  const UploadInquiryPhotoParams({
    required this.bytes,
    required this.fileName,
    this.maxBytes,
  });

  @override
  List<Object?> get props => [bytes, fileName, maxBytes];
}
