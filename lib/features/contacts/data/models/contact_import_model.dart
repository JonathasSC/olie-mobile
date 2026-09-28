import 'package:olie/features/contacts/domain/entities/contact_import.dart';

abstract final class ContactImportModel {
  static ContactImportResult resultFromJson(Map<String, dynamic> json) {
    return ContactImportResult(
      categoriesCreated: (json['categoriesCreated'] as num).toInt(),
      contactsCreated: (json['contactsCreated'] as num).toInt(),
      contactsUpdated: (json['contactsUpdated'] as num).toInt(),
    );
  }

  /// `details` do erro `INVALID_CONTACTS_FILE`.
  static List<ContactFileError> errorsFromJson(Object? details) {
    if (details is! List) return const [];
    return details
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => ContactFileError(
            line: (json['line'] as num?)?.toInt() ?? 0,
            field: json['field'] as String?,
            message: json['message'] as String,
          ),
        )
        .toList();
  }
}
