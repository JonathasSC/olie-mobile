import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';
import 'package:olie/features/contacts/domain/usecases/add_contact.dart';
import 'package:olie/features/contacts/domain/usecases/add_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/delete_contact.dart';
import 'package:olie/features/contacts/domain/usecases/delete_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/export_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/get_contact_categories.dart';
import 'package:olie/features/contacts/domain/usecases/get_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/import_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/rename_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/update_contact.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';

class MockGetContacts extends Mock implements GetContacts {}

class MockGetContactCategories extends Mock implements GetContactCategories {}

class MockImportContacts extends Mock implements ImportContacts {}

class MockDeleteContactCategory extends Mock implements DeleteContactCategory {}

void main() {
  late MockGetContacts getContacts;
  late MockGetContactCategories getCategories;
  late MockImportContacts importContacts;
  late MockDeleteContactCategory deleteCategory;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      ImportContactsParams(bytes: Uint8List(0), fileName: 'x.yaml'),
    );
    registerFallbackValue(const DeleteContactCategoryParams(id: 'x'));
  });

  setUp(() {
    getContacts = MockGetContacts();
    getCategories = MockGetContactCategories();
    importContacts = MockImportContacts();
    deleteCategory = MockDeleteContactCategory();
    when(() => getContacts(any())).thenAnswer((_) async => const Right([]));
    when(() => getCategories(any())).thenAnswer(
      (_) async => const Right([
        ContactCategory(id: 'c1', name: 'Farmácias', contactsCount: 0),
      ]),
    );
  });

  ContactBloc build() => ContactBloc(
    getContacts: getContacts,
    getContactCategories: getCategories,
    addContact: AddContact(_UnusedRepository()),
    updateContact: UpdateContact(_UnusedRepository()),
    deleteContact: DeleteContact(_UnusedRepository()),
    addContactCategory: AddContactCategory(_UnusedRepository()),
    renameContactCategory: RenameContactCategory(_UnusedRepository()),
    deleteContactCategory: deleteCategory,
    importContacts: importContacts,
    exportContacts: ExportContacts(_UnusedRepository()),
  );

  blocTest<ContactBloc, ContactState>(
    'importação recusada expõe a linha de cada problema',
    build: () {
      when(() => importContacts(any())).thenAnswer(
        (_) async => const Left(
          InvalidContactsFileFailure('O arquivo tem 1 problema(s).', [
            ContactFileError(line: 7, field: 'phone', message: 'inválido'),
          ]),
        ),
      );
      return build();
    },
    act: (bloc) => bloc.add(
      ContactsImportRequested(bytes: Uint8List(1), fileName: 'contatos.yaml'),
    ),
    verify: (bloc) {
      expect(bloc.state.importStatus, ContactImportStatus.failure);
      expect(bloc.state.importErrors.single.line, 7);
    },
  );

  blocTest<ContactBloc, ContactState>(
    'importação aceita recarrega contatos e categorias',
    build: () {
      when(() => importContacts(any())).thenAnswer(
        (_) async => const Right(
          ContactImportResult(
            categoriesCreated: 1,
            contactsCreated: 2,
            contactsUpdated: 0,
          ),
        ),
      );
      return build();
    },
    act: (bloc) => bloc.add(
      ContactsImportRequested(bytes: Uint8List(1), fileName: 'contatos.json'),
    ),
    verify: (bloc) {
      expect(bloc.state.importStatus, ContactImportStatus.success);
      expect(bloc.state.importResult?.contactsCreated, 2);
      expect(bloc.state.categories.single.name, 'Farmácias');
      verify(() => getCategories(any())).called(1);
    },
  );

  blocTest<ContactBloc, ContactState>(
    'remover categoria em uso envia a confirmação de desvincular',
    build: () {
      when(() => deleteCategory(any())).thenAnswer((_) async => const Right(null));
      return build();
    },
    act: (bloc) => bloc.add(
      const ContactCategoryDeleted(id: 'c1', unlinkContacts: true),
    ),
    verify: (_) => verify(
      () => deleteCategory(
        const DeleteContactCategoryParams(id: 'c1', unlinkContacts: true),
      ),
    ).called(1),
  );
}

/// Os casos de uso que estes testes não exercitam recebem um repositório vazio.
class _UnusedRepository extends Mock implements ContactRepository {}
