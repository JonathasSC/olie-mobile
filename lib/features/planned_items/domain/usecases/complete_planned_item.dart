import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class CompletePlannedItem
    implements UseCase<void, CompletePlannedItemParams> {
  final PlannedItemRepository repository;

  CompletePlannedItem(this.repository);

  @override
  Future<Either<Failure, void>> call(CompletePlannedItemParams params) {
    return repository.completePlannedItem(
      id: params.id,
      paymentMethod: params.paymentMethod,
      value: params.value,
    );
  }
}

class CompletePlannedItemParams extends Equatable {
  final String id;
  final String paymentMethod;
  final double? value;

  const CompletePlannedItemParams({
    required this.id,
    required this.paymentMethod,
    this.value,
  });

  @override
  List<Object?> get props => [id, paymentMethod, value];
}
