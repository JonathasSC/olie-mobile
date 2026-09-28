import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';

class ContactImportResult extends Equatable {
  final int categoriesCreated;
  final int contactsCreated;
  final int contactsUpdated;

  const ContactImportResult({
    required this.categoriesCreated,
    required this.contactsCreated,
    required this.contactsUpdated,
  });

  @override
  List<Object?> get props => [categoriesCreated, contactsCreated, contactsUpdated];
}

/// Problema de um arquivo importado, com a linha para o usuário localizar.
class ContactFileError extends Equatable {
  final int line;
  final String? field;
  final String message;

  const ContactFileError({required this.line, this.field, required this.message});

  @override
  List<Object?> get props => [line, field, message];
}

/// O arquivo tem erros: nada foi importado. [errors] lista cada problema.
class InvalidContactsFileFailure extends Failure {
  final List<ContactFileError> errors;

  const InvalidContactsFileFailure(super.message, this.errors);

  @override
  List<Object?> get props => [message, errors];
}
