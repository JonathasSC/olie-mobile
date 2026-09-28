import 'package:olie/features/contacts/domain/entities/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.categoryIds,
    required super.active,
    required super.doNotContact,
    required super.contactable,
    required super.createdAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      categoryIds: (json['categoryIds'] as List<dynamic>).cast<String>(),
      active: json['active'] as bool,
      doNotContact: json['doNotContact'] as bool,
      contactable: json['contactable'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> encodeRequest({
    required String name,
    required String phone,
    required Set<String> categoryIds,
    bool? active,
    bool? doNotContact,
  }) {
    return {
      'name': name,
      'phone': phone,
      'categoryIds': categoryIds.toList(),
      'active': ?active,
      'doNotContact': ?doNotContact,
    };
  }
}
