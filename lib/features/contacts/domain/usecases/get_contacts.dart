import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class GetContacts implements UseCase<List<Contact>, NoParams> {
  final ContactRepository repository;

  GetContacts(this.repository);

  @override
  Future<Either<Failure, List<Contact>>> call(NoParams params) {
    return repository.getContacts();
  }
}
