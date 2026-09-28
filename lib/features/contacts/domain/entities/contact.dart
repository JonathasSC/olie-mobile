import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String name;

  /// Telefone em E.164 (ex.: `+5511999999999`).
  final String phone;
  final List<String> categoryIds;
  final bool active;

  /// Pediu para não ser contatado: fica fora de qualquer consulta.
  final bool doNotContact;

  /// Pode receber consultas (ativo e sem [doNotContact]).
  final bool contactable;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.categoryIds,
    required this.active,
    required this.doNotContact,
    required this.contactable,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    categoryIds,
    active,
    doNotContact,
    contactable,
    createdAt,
  ];
}
