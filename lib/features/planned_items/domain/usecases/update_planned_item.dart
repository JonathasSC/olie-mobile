import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class UpdatePlannedItem
    implements UseCase<PlannedItem, UpdatePlannedItemParams> {
  final PlannedItemRepository repository;

  UpdatePlannedItem(this.repository);

  @override
  Future<Either<Failure, PlannedItem>> call(UpdatePlannedItemParams params) {
    return repository.updatePlannedItem(
      id: params.id,
      name: params.name,
      priority: params.priority,
      estimatedValue: params.estimatedValue,
      estimatedDate: params.estimatedDate,
      categoryId: params.categoryId,
    );
  }
}

class UpdatePlannedItemParams extends Equatable {
  final String id;
  final String name;
  final PlannedItemPriority priority;
  final double estimatedValue;
  final DateTime estimatedDate;
  final String? categoryId;

  const UpdatePlannedItemParams({
    required this.id,
    required this.name,
    required this.priority,
    required this.estimatedValue,
    required this.estimatedDate,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    priority,
    estimatedValue,
    estimatedDate,
    categoryId,
  ];
}
