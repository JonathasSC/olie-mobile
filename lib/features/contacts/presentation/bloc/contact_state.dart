part of 'contact_bloc.dart';

enum ContactStatus { initial, loading, success, failure }

enum ContactImportStatus { idle, importing, success, failure }

class ContactState extends Equatable {
  final ContactStatus status;
  final List<Contact> contacts;
  final List<ContactCategory> categories;
  final String? errorMessage;

  final ContactImportStatus importStatus;
  final ContactImportResult? importResult;
  final String? importMessage;

  /// Problemas do arquivo, com a linha de cada um (importação recusada).
  final List<ContactFileError> importErrors;

  /// Arquivo exportado aguardando a tela salvar.
  final ContactFile? exportFile;

  const ContactState({
    this.status = ContactStatus.initial,
    this.contacts = const [],
    this.categories = const [],
    this.errorMessage,
    this.importStatus = ContactImportStatus.idle,
    this.importResult,
    this.importMessage,
    this.importErrors = const [],
    this.exportFile,
  });

  ContactCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  ContactState copyWith({
    ContactStatus? status,
    List<Contact>? contacts,
    List<ContactCategory>? categories,
    String? errorMessage,
    ContactImportStatus? importStatus,
    ContactImportResult? importResult,
    String? importMessage,
    List<ContactFileError>? importErrors,
    ContactFile? exportFile,
    bool clearImport = false,
    bool clearExport = false,
  }) {
    return ContactState(
      status: status ?? this.status,
      contacts: contacts ?? this.contacts,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      importStatus: clearImport
          ? ContactImportStatus.idle
          : importStatus ?? this.importStatus,
      importResult: clearImport ? null : importResult ?? this.importResult,
      importMessage: clearImport ? null : importMessage ?? this.importMessage,
      importErrors: clearImport ? const [] : importErrors ?? this.importErrors,
      exportFile: clearExport ? null : exportFile ?? this.exportFile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    contacts,
    categories,
    errorMessage,
    importStatus,
    importResult,
    importMessage,
    importErrors,
    exportFile,
  ];
}
