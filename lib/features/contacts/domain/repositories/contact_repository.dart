import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';

abstract class ContactRepository {
  Future<Either<Failure, List<Contact>>> getContacts();

  Future<Either<Failure, List<ContactCategory>>> getContactCategories();

  Future<Either<Failure, Contact>> addContact({
    required String name,
    required String phone,
    required Set<String> categoryIds,
    bool? active,
    bool? doNotContact,
  });

  Future<Either<Failure, Contact>> updateContact({
    required String id,
    required String name,
    required String phone,
    required Set<String> categoryIds,
    bool? active,
    bool? doNotContact,
  });

  Future<Either<Failure, void>> deleteContact(String id);

  Future<Either<Failure, ContactCategory>> addContactCategory(String name);

  Future<Either<Failure, ContactCategory>> renameContactCategory({
    required String id,
    required String name,
  });

  Future<Either<Failure, void>> deleteContactCategory({
    required String id,
    required bool unlinkContacts,
  });

  Future<Either<Failure, ContactImportResult>> importContacts({
    required Uint8List bytes,
    required String fileName,
  });

  Future<Either<Failure, ContactFile>> exportContacts(ContactFileFormat format);
}
