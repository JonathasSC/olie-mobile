import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

/// Registra a troca: encerra o ciclo atual (move para o histórico) e inicia
/// um novo com a unidade nova.
class ReplaceWearItem implements UseCase<WearItem, ReplaceWearItemParams> {
  final WearItemRepository repository;

  ReplaceWearItem(this.repository);

  @override
  Future<Either<Failure, WearItem>> call(ReplaceWearItemParams params) async {
    // A API só gera a transação quando os dois vêm juntos e responde 400
    // caso contrário — validamos antes para dar uma mensagem clara.
    if (params.paymentMethod != null && params.purchaseValue == null) {
      return const Left(
        ValidationFailure(
          'Informe o valor pago para registrar a forma de pagamento.',
        ),
      );
    }

    return repository.replaceWearItem(
      id: params.id,
      purchaseDate: params.purchaseDate,
      installationDate: params.installationDate,
      removalDate: params.removalDate,
      purchaseValue: params.purchaseValue,
      paymentMethod: params.paymentMethod,
    );
  }
}

class ReplaceWearItemParams extends Equatable {
  final String id;
  final DateTime purchaseDate;
  final DateTime? installationDate;
  final DateTime? removalDate;
  final double? purchaseValue;
  final String? paymentMethod;

  const ReplaceWearItemParams({
    required this.id,
    required this.purchaseDate,
    this.installationDate,
    this.removalDate,
    this.purchaseValue,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    purchaseDate,
    installationDate,
    removalDate,
    purchaseValue,
    paymentMethod,
  ];
}
