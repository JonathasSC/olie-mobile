import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class RenameContactCategory
    implements UseCase<ContactCategory, RenameContactCategoryParams> {
  final ContactRepository repository;

  RenameContactCategory(this.repository);

  @override
  Future<Either<Failure, ContactCategory>> call(
    RenameContactCategoryParams params,
  ) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Left(ValidationFailure('Informe o nome da categoria.'));
    }
    return repository.renameContactCategory(id: params.id, name: name);
  }
}

class RenameContactCategoryParams extends Equatable {
  final String id;
  final String name;

  const RenameContactCategoryParams({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
