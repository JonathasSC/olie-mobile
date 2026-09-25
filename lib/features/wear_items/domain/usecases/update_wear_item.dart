import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

/// Corrige os dados do item e do ciclo atual. Para registrar uma unidade
/// nova, use [ReplaceWearItem].
class UpdateWearItem implements UseCase<WearItem, UpdateWearItemParams> {
  final WearItemRepository repository;

  UpdateWearItem(this.repository);

  @override
  Future<Either<Failure, WearItem>> call(UpdateWearItemParams params) {
    return repository.updateWearItem(
      id: params.id,
      name: params.name,
      expectedLifespan: params.expectedLifespan,
      expectedLifespanUnit: params.expectedLifespanUnit,
      purchaseDate: params.purchaseDate,
      installationDate: params.installationDate,
      purchaseValue: params.purchaseValue,
      categoryId: params.categoryId,
    );
  }
}

class UpdateWearItemParams extends Equatable {
  final String id;
  final String name;
  final int expectedLifespan;
  final LifespanUnit expectedLifespanUnit;
  final DateTime purchaseDate;
  final DateTime? installationDate;
  final double? purchaseValue;
  final String? categoryId;

  const UpdateWearItemParams({
    required this.id,
    required this.name,
    required this.expectedLifespan,
    required this.expectedLifespanUnit,
    required this.purchaseDate,
    this.installationDate,
    this.purchaseValue,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    expectedLifespan,
    expectedLifespanUnit,
    purchaseDate,
    installationDate,
    purchaseValue,
    categoryId,
  ];
}
