import 'package:equatable/equatable.dart';

/// Categoria de contato ("Farmácias", "Fornecedores") — independente das
/// categorias financeiras.
class ContactCategory extends Equatable {
  final String id;
  final String name;
  final int contactsCount;

  const ContactCategory({
    required this.id,
    required this.name,
    required this.contactsCount,
  });

  @override
  List<Object?> get props => [id, name, contactsCount];
}
