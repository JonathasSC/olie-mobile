import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';
import 'package:olie/features/contacts/domain/usecases/contact_validation.dart';

class UpdateContact implements UseCase<Contact, UpdateContactParams> {
  final ContactRepository repository;

  UpdateContact(this.repository);

  @override
  Future<Either<Failure, Contact>> call(UpdateContactParams params) async {
    final validated = validateContact(
      name: params.name,
      phone: params.phone,
      categoryIds: params.categoryIds,
    );
    return validated.fold(
      (failure) async => Left(failure),
      (contact) => repository.updateContact(
        id: params.id,
        name: contact.name,
        phone: contact.phone,
        categoryIds: params.categoryIds,
        active: params.active,
        doNotContact: params.doNotContact,
      ),
    );
  }
}

class UpdateContactParams extends Equatable {
  final String id;
  final String name;
  final String phone;
  final Set<String> categoryIds;
  final bool active;
  final bool doNotContact;

  const UpdateContactParams({
    required this.id,
    required this.name,
    required this.phone,
    required this.categoryIds,
    required this.active,
    required this.doNotContact,
  });

  @override
  List<Object?> get props => [id, name, phone, categoryIds, active, doNotContact];
}
