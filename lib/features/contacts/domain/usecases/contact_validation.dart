import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/contacts/domain/entities/phone_number.dart';

/// Dados de contato já validados e normalizados.
typedef ValidContact = ({String name, String phone});

/// Mesmas regras da API, checadas antes da rede para dar a mensagem certa.
Either<Failure, ValidContact> validateContact({
  required String name,
  required String phone,
  required Set<String> categoryIds,
}) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    return const Left(ValidationFailure('Informe o nome do contato.'));
  }
  final normalized = normalizePhone(phone);
  if (normalized == null) {
    return const Left(
      ValidationFailure(
        'Telefone inválido: use o formato internacional com código do país, '
        'ex.: +55 11 99999-9999.',
      ),
    );
  }
  if (categoryIds.isEmpty) {
    return const Left(ValidationFailure('Escolha ao menos uma categoria.'));
  }
  return Right((name: trimmedName, phone: normalized));
}
