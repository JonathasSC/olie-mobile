import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

/// Importa um arquivo `.yaml`/`.yml`/`.json`. Tudo ou nada: com erros, a
/// falha é [InvalidContactsFileFailure] com a linha de cada problema.
class ImportContacts
    implements UseCase<ContactImportResult, ImportContactsParams> {
  static const _extensions = ['.yaml', '.yml', '.json'];

  final ContactRepository repository;

  ImportContacts(this.repository);

  @override
  Future<Either<Failure, ContactImportResult>> call(
    ImportContactsParams params,
  ) async {
    final lower = params.fileName.toLowerCase();
    if (!_extensions.any(lower.endsWith)) {
      return const Left(
        ValidationFailure('Use um arquivo .yaml, .yml ou .json.'),
      );
    }
    return repository.importContacts(
      bytes: params.bytes,
      fileName: params.fileName,
    );
  }
}

class ImportContactsParams extends Equatable {
  final Uint8List bytes;
  final String fileName;

  const ImportContactsParams({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [bytes, fileName];
}
