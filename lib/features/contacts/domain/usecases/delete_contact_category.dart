import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class DeleteContactCategory
    implements UseCase<void, DeleteContactCategoryParams> {
  final ContactRepository repository;

  DeleteContactCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteContactCategoryParams params) {
    return repository.deleteContactCategory(
      id: params.id,
      unlinkContacts: params.unlinkContacts,
    );
  }
}

class DeleteContactCategoryParams extends Equatable {
  final String id;

  /// Confirmação para remover uma categoria que ainda tem contatos: eles
  /// perdem só esse vínculo.
  final bool unlinkContacts;

  const DeleteContactCategoryParams({
    required this.id,
    this.unlinkContacts = false,
  });

  @override
  List<Object?> get props => [id, unlinkContacts];
}
