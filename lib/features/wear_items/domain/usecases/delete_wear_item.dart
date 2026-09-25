import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

class DeleteWearItem implements UseCase<void, DeleteWearItemParams> {
  final WearItemRepository repository;

  DeleteWearItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteWearItemParams params) {
    return repository.deleteWearItem(params.id);
  }
}

class DeleteWearItemParams extends Equatable {
  final String id;

  const DeleteWearItemParams(this.id);

  @override
  List<Object?> get props => [id];
}
