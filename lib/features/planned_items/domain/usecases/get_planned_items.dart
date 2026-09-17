import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class GetPlannedItems implements UseCase<List<PlannedItem>, NoParams> {
  final PlannedItemRepository repository;

  GetPlannedItems(this.repository);

  @override
  Future<Either<Failure, List<PlannedItem>>> call(NoParams params) {
    return repository.getPlannedItems();
  }
}
