import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

/// Enfileira a consulta (o envio começa em até 1 s). Pode falhar com
/// [DuplicateInquiryFailure]: repita com `confirmDuplicates: true` depois
/// que o usuário confirmar.
class CreateInquiry implements UseCase<Inquiry, CreateInquiryParams> {
  final InquiryRepository repository;

  CreateInquiry(this.repository);

  @override
  Future<Either<Failure, Inquiry>> call(CreateInquiryParams params) async {
    if (params.contactIds.isEmpty) {
      return const Left(ValidationFailure('Escolha ao menos um contato.'));
    }
    if (params.items.isEmpty) {
      return const Left(ValidationFailure('Adicione ao menos um item.'));
    }
    if (params.items.any((item) => item.name.trim().isEmpty)) {
      return const Left(ValidationFailure('Todo item precisa de um nome.'));
    }
    final maxItems = params.maxItems;
    if (maxItems != null && params.items.length > maxItems) {
      return Left(
        ValidationFailure('Uma consulta pode ter no máximo $maxItems itens.'),
      );
    }
    final maxRecipients = params.maxRecipients;
    if (maxRecipients != null && params.contactIds.length > maxRecipients) {
      return Left(
        ValidationFailure(
          'Uma consulta pode ter no máximo $maxRecipients contatos.',
        ),
      );
    }

    return repository.createInquiry(
      categoryIds: params.categoryIds,
      contactIds: params.contactIds,
      items: [
        for (final item in params.items)
          InquiryItemDraft(name: item.name.trim(), photoId: item.photoId),
      ],
      simulate: params.simulate,
      confirmDuplicates: params.confirmDuplicates,
    );
  }
}

class CreateInquiryParams extends Equatable {
  final Set<String> categoryIds;

  /// Destinatários na ordem de envio.
  final List<String> contactIds;
  final List<InquiryItemDraft> items;
  final bool simulate;
  final bool confirmDuplicates;

  /// Limites do backend (de [InquirySettings]), checados antes da rede.
  final int? maxItems;
  final int? maxRecipients;

  const CreateInquiryParams({
    this.categoryIds = const {},
    required this.contactIds,
    required this.items,
    this.simulate = false,
    this.confirmDuplicates = false,
    this.maxItems,
    this.maxRecipients,
  });

  @override
  List<Object?> get props => [
    categoryIds,
    contactIds,
    items,
    simulate,
    confirmDuplicates,
    maxItems,
    maxRecipients,
  ];
}
