import 'package:olie/features/contacts/domain/entities/contact_category.dart';

class ContactCategoryModel extends ContactCategory {
  const ContactCategoryModel({
    required super.id,
    required super.name,
    required super.contactsCount,
  });

  factory ContactCategoryModel.fromJson(Map<String, dynamic> json) {
    return ContactCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      contactsCount: (json['contactsCount'] as num).toInt(),
    );
  }
}
