import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class ExportContacts implements UseCase<ContactFile, ExportContactsParams> {
  final ContactRepository repository;

  ExportContacts(this.repository);

  @override
  Future<Either<Failure, ContactFile>> call(ExportContactsParams params) {
    return repository.exportContacts(params.format);
  }
}

class ExportContactsParams extends Equatable {
  final ContactFileFormat format;

  const ExportContactsParams(this.format);

  @override
  List<Object?> get props => [format];
}
