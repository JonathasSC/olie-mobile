part of 'contact_bloc.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => [];
}

class ContactsRequested extends ContactEvent {
  const ContactsRequested();
}

class ContactAdded extends ContactEvent {
  final String name;
  final String phone;
  final Set<String> categoryIds;
  final bool active;
  final bool doNotContact;

  const ContactAdded({
    required this.name,
    required this.phone,
    required this.categoryIds,
    this.active = true,
    this.doNotContact = false,
  });

  @override
  List<Object?> get props => [name, phone, categoryIds, active, doNotContact];
}

class ContactUpdated extends ContactEvent {
  final String id;
  final String name;
  final String phone;
  final Set<String> categoryIds;
  final bool active;
  final bool doNotContact;

  const ContactUpdated({
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

class ContactDeleted extends ContactEvent {
  final String id;

  const ContactDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class ContactCategoryAdded extends ContactEvent {
  final String name;

  const ContactCategoryAdded(this.name);

  @override
  List<Object?> get props => [name];
}

class ContactCategoryRenamed extends ContactEvent {
  final String id;
  final String name;

  const ContactCategoryRenamed({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class ContactCategoryDeleted extends ContactEvent {
  final String id;
  final bool unlinkContacts;

  const ContactCategoryDeleted({required this.id, this.unlinkContacts = false});

  @override
  List<Object?> get props => [id, unlinkContacts];
}

class ContactsImportRequested extends ContactEvent {
  final Uint8List bytes;
  final String fileName;

  const ContactsImportRequested({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [bytes, fileName];
}

/// O usuário fechou o resultado da importação.
class ContactsImportDismissed extends ContactEvent {
  const ContactsImportDismissed();
}

class ContactsExportRequested extends ContactEvent {
  final ContactFileFormat format;

  const ContactsExportRequested(this.format);

  @override
  List<Object?> get props => [format];
}

/// A tela já salvou o arquivo exportado.
class ContactsExportHandled extends ContactEvent {
  const ContactsExportHandled();
}
