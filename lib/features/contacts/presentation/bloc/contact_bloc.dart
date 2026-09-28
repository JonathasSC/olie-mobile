import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';
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

part 'contact_event.dart';
part 'contact_state.dart';

/// Contatos e categorias de contato juntos: quase toda mudança em um afeta
/// o outro (a contagem de contatos por categoria, os vínculos).
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetContacts getContacts;
  final GetContactCategories getContactCategories;
  final AddContact addContact;
  final UpdateContact updateContact;
  final DeleteContact deleteContact;
  final AddContactCategory addContactCategory;
  final RenameContactCategory renameContactCategory;
  final DeleteContactCategory deleteContactCategory;
  final ImportContacts importContacts;
  final ExportContacts exportContacts;

  ContactBloc({
    required this.getContacts,
    required this.getContactCategories,
    required this.addContact,
    required this.updateContact,
    required this.deleteContact,
    required this.addContactCategory,
    required this.renameContactCategory,
    required this.deleteContactCategory,
    required this.importContacts,
    required this.exportContacts,
  }) : super(const ContactState()) {
    on<ContactsRequested>(_onContactsRequested);
    on<ContactAdded>(_onContactAdded);
    on<ContactUpdated>(_onContactUpdated);
    on<ContactDeleted>(_onContactDeleted);
    on<ContactCategoryAdded>(_onContactCategoryAdded);
    on<ContactCategoryRenamed>(_onContactCategoryRenamed);
    on<ContactCategoryDeleted>(_onContactCategoryDeleted);
    on<ContactsImportRequested>(_onContactsImportRequested);
    on<ContactsImportDismissed>(
      (event, emit) => emit(state.copyWith(clearImport: true)),
    );
    on<ContactsExportRequested>(_onContactsExportRequested);
    on<ContactsExportHandled>(
      (event, emit) => emit(state.copyWith(clearExport: true)),
    );
  }

  Future<void> _onContactsRequested(
    ContactsRequested event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(status: ContactStatus.loading));
    await _reload(emit);
  }

  Future<void> _onContactAdded(
    ContactAdded event,
    Emitter<ContactState> emit,
  ) async {
    final result = await addContact(
      AddContactParams(
        name: event.name,
        phone: event.phone,
        categoryIds: event.categoryIds,
        active: event.active,
        doNotContact: event.doNotContact,
      ),
    );
    await result.fold(
      (failure) async => _fail(emit, failure),
      (contact) async {
        emit(state.copyWith(
          status: ContactStatus.success,
          contacts: _sorted([...state.contacts, contact]),
        ));
        await _reloadCategories(emit);
      },
    );
  }

  Future<void> _onContactUpdated(
    ContactUpdated event,
    Emitter<ContactState> emit,
  ) async {
    final result = await updateContact(
      UpdateContactParams(
        id: event.id,
        name: event.name,
        phone: event.phone,
        categoryIds: event.categoryIds,
        active: event.active,
        doNotContact: event.doNotContact,
      ),
    );
    await result.fold(
      (failure) async => _fail(emit, failure),
      (contact) async {
        emit(state.copyWith(
          status: ContactStatus.success,
          contacts: _sorted([
            for (final current in state.contacts)
              current.id == contact.id ? contact : current,
          ]),
        ));
        await _reloadCategories(emit);
      },
    );
  }

  Future<void> _onContactDeleted(
    ContactDeleted event,
    Emitter<ContactState> emit,
  ) async {
    final result = await deleteContact(DeleteContactParams(event.id));
    await result.fold(
      (failure) async => _fail(emit, failure),
      (_) async {
        emit(state.copyWith(
          status: ContactStatus.success,
          contacts: state.contacts.where((c) => c.id != event.id).toList(),
        ));
        await _reloadCategories(emit);
      },
    );
  }

  Future<void> _onContactCategoryAdded(
    ContactCategoryAdded event,
    Emitter<ContactState> emit,
  ) async {
    final result = await addContactCategory(
      AddContactCategoryParams(event.name),
    );
    result.fold(
      (failure) => _fail(emit, failure),
      (category) => emit(state.copyWith(
        status: ContactStatus.success,
        categories: _sortedCategories([...state.categories, category]),
      )),
    );
  }

  Future<void> _onContactCategoryRenamed(
    ContactCategoryRenamed event,
    Emitter<ContactState> emit,
  ) async {
    final result = await renameContactCategory(
      RenameContactCategoryParams(id: event.id, name: event.name),
    );
    result.fold(
      (failure) => _fail(emit, failure),
      (category) => emit(state.copyWith(
        status: ContactStatus.success,
        categories: _sortedCategories([
          for (final current in state.categories)
            current.id == category.id ? category : current,
        ]),
      )),
    );
  }

  Future<void> _onContactCategoryDeleted(
    ContactCategoryDeleted event,
    Emitter<ContactState> emit,
  ) async {
    final result = await deleteContactCategory(
      DeleteContactCategoryParams(
        id: event.id,
        unlinkContacts: event.unlinkContacts,
      ),
    );
    // Os contatos perderam o vínculo: recarrega os dois lados.
    await result.fold(
      (failure) async => _fail(emit, failure),
      (_) => _reload(emit),
    );
  }

  Future<void> _onContactsImportRequested(
    ContactsImportRequested event,
    Emitter<ContactState> emit,
  ) async {
    emit(state.copyWith(importStatus: ContactImportStatus.importing));

    final result = await importContacts(
      ImportContactsParams(bytes: event.bytes, fileName: event.fileName),
    );
    await result.fold(
      (failure) async => emit(state.copyWith(
        importStatus: ContactImportStatus.failure,
        importMessage: failure.message,
        importErrors: failure is InvalidContactsFileFailure
            ? failure.errors
            : const [],
      )),
      (importResult) async {
        emit(state.copyWith(
          importStatus: ContactImportStatus.success,
          importResult: importResult,
        ));
        await _reload(emit);
      },
    );
  }

  Future<void> _onContactsExportRequested(
    ContactsExportRequested event,
    Emitter<ContactState> emit,
  ) async {
    final result = await exportContacts(ExportContactsParams(event.format));
    result.fold(
      (failure) => _fail(emit, failure),
      (file) => emit(state.copyWith(exportFile: file)),
    );
  }

  Future<void> _reload(Emitter<ContactState> emit) async {
    final contacts = await getContacts(const NoParams());
    final categories = await getContactCategories(const NoParams());

    contacts.fold(
      (failure) => _fail(emit, failure),
      (contacts) => categories.fold(
        (failure) => _fail(emit, failure),
        (categories) => emit(state.copyWith(
          status: ContactStatus.success,
          contacts: contacts,
          categories: categories,
        )),
      ),
    );
  }

  /// Contagem de contatos por categoria mudou.
  Future<void> _reloadCategories(Emitter<ContactState> emit) async {
    final result = await getContactCategories(const NoParams());
    result.fold(
      (_) {},
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  void _fail(Emitter<ContactState> emit, Failure failure) {
    emit(state.copyWith(
      status: ContactStatus.failure,
      errorMessage: failure.message,
    ));
  }

  static List<Contact> _sorted(List<Contact> contacts) => contacts
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  static List<ContactCategory> _sortedCategories(
    List<ContactCategory> categories,
  ) => categories
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
