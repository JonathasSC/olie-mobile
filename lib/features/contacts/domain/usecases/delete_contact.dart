import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class DeleteContact implements UseCase<void, DeleteContactParams> {
  final ContactRepository repository;

  DeleteContact(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteContactParams params) {
    return repository.deleteContact(params.id);
  }
}

class DeleteContactParams extends Equatable {
  final String id;

  const DeleteContactParams(this.id);

  @override
  List<Object?> get props => [id];
}
