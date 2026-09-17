import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class AddPlannedItem implements UseCase<PlannedItem, AddPlannedItemParams> {
  final PlannedItemRepository repository;

  AddPlannedItem(this.repository);

  @override
  Future<Either<Failure, PlannedItem>> call(AddPlannedItemParams params) {
    return repository.addPlannedItem(
      name: params.name,
      priority: params.priority,
      estimatedValue: params.estimatedValue,
      estimatedDate: params.estimatedDate,
      categoryId: params.categoryId,
    );
  }
}

class AddPlannedItemParams extends Equatable {
  final String name;
  final PlannedItemPriority priority;
  final double estimatedValue;
  final DateTime estimatedDate;
  final String? categoryId;

  const AddPlannedItemParams({
    required this.name,
    required this.priority,
    required this.estimatedValue,
    required this.estimatedDate,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    name,
    priority,
    estimatedValue,
    estimatedDate,
    categoryId,
  ];
}
