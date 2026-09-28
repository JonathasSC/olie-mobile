import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class GetContactCategories implements UseCase<List<ContactCategory>, NoParams> {
  final ContactRepository repository;

  GetContactCategories(this.repository);

  @override
  Future<Either<Failure, List<ContactCategory>>> call(NoParams params) {
    return repository.getContactCategories();
  }
}
