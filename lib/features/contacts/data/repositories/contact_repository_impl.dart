import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/contacts/data/datasources/contact_remote_data_source.dart';
import 'package:olie/features/contacts/data/models/contact_import_model.dart';
import 'package:olie/features/contacts/data/models/contact_model.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDataSource remoteDataSource;

  ContactRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Contact>>> getContacts() {
    return _request(remoteDataSource.getContacts);
  }

  @override
  Future<Either<Failure, List<ContactCategory>>> getContactCategories() {
    return _request(remoteDataSource.getContactCategories);
  }

  @override
  Future<Either<Failure, Contact>> addContact({
    required String name,
    required String phone,
    required Set<String> categoryIds,
    bool? active,
    bool? doNotContact,
  }) {
    return _request(
      () => remoteDataSource.addContact(
        ContactModel.encodeRequest(
          name: name,
          phone: phone,
          categoryIds: categoryIds,
          active: active,
          doNotContact: doNotContact,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, Contact>> updateContact({
    required String id,
    required String name,
    required String phone,
    required Set<String> categoryIds,
    bool? active,
    bool? doNotContact,
  }) {
    return _request(
      () => remoteDataSource.updateContact(
        id,
        ContactModel.encodeRequest(
          name: name,
          phone: phone,
          categoryIds: categoryIds,
          active: active,
          doNotContact: doNotContact,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteContact(String id) {
    return _request(() => remoteDataSource.deleteContact(id));
  }

  @override
  Future<Either<Failure, ContactCategory>> addContactCategory(String name) {
    return _request(() => remoteDataSource.addContactCategory(name));
  }

  @override
  Future<Either<Failure, ContactCategory>> renameContactCategory({
    required String id,
    required String name,
  }) {
    return _request(() => remoteDataSource.renameContactCategory(id, name));
  }

  @override
  Future<Either<Failure, void>> deleteContactCategory({
    required String id,
    required bool unlinkContacts,
  }) {
    return _request(
      () => remoteDataSource.deleteContactCategory(
        id,
        unlinkContacts: unlinkContacts,
      ),
    );
  }

  @override
  Future<Either<Failure, ContactImportResult>> importContacts({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      return Right(await remoteDataSource.importContacts(bytes, fileName));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      if (e.code == 'INVALID_CONTACTS_FILE') {
        return Left(
          InvalidContactsFileFailure(
            e.message,
            ContactImportModel.errorsFromJson(e.details),
          ),
        );
      }
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, ContactFile>> exportContacts(ContactFileFormat format) {
    return _request(() => remoteDataSource.exportContacts(format));
  }

  Future<Either<Failure, T>> _request<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }
}
