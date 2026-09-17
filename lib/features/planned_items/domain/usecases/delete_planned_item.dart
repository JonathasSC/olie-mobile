import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class DeletePlannedItem implements UseCase<void, DeletePlannedItemParams> {
  final PlannedItemRepository repository;

  DeletePlannedItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePlannedItemParams params) {
    return repository.deletePlannedItem(params.id);
  }
}

class DeletePlannedItemParams extends Equatable {
  final String id;

  const DeletePlannedItemParams(this.id);

  @override
  List<Object?> get props => [id];
}
