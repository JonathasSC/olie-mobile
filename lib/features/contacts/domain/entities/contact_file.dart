import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ContactFileFormat {
  yaml,
  json;

  String get apiValue => name.toUpperCase();

  String get extension => name;
}

/// Arquivo de contatos pronto para salvar (exportação).
class ContactFile extends Equatable {
  final String fileName;
  final Uint8List bytes;

  const ContactFile({required this.fileName, required this.bytes});

  @override
  List<Object?> get props => [fileName, bytes];
}
