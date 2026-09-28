import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class AddContactCategory
    implements UseCase<ContactCategory, AddContactCategoryParams> {
  final ContactRepository repository;

  AddContactCategory(this.repository);

  @override
  Future<Either<Failure, ContactCategory>> call(
    AddContactCategoryParams params,
  ) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Left(ValidationFailure('Informe o nome da categoria.'));
    }
    return repository.addContactCategory(name);
  }
}

class AddContactCategoryParams extends Equatable {
  final String name;

  const AddContactCategoryParams(this.name);

  @override
  List<Object?> get props => [name];
}
