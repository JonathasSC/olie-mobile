import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';
import 'package:olie/features/contacts/domain/usecases/contact_validation.dart';

class AddContact implements UseCase<Contact, AddContactParams> {
  final ContactRepository repository;

  AddContact(this.repository);

  @override
  Future<Either<Failure, Contact>> call(AddContactParams params) async {
    final validated = validateContact(
      name: params.name,
      phone: params.phone,
      categoryIds: params.categoryIds,
    );
    return validated.fold(
      (failure) async => Left(failure),
      (contact) => repository.addContact(
        name: contact.name,
        phone: contact.phone,
        categoryIds: params.categoryIds,
        active: params.active,
        doNotContact: params.doNotContact,
      ),
    );
  }
}

class AddContactParams extends Equatable {
  final String name;
  final String phone;
  final Set<String> categoryIds;
  final bool active;
  final bool doNotContact;

  const AddContactParams({
    required this.name,
    required this.phone,
    required this.categoryIds,
    this.active = true,
    this.doNotContact = false,
  });

  @override
  List<Object?> get props => [name, phone, categoryIds, active, doNotContact];
}
