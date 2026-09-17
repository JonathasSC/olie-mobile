import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

abstract class PlannedItemRepository {
  Future<Either<Failure, List<PlannedItem>>> getPlannedItems();

  Future<Either<Failure, PlannedItem>> addPlannedItem({
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  });

  Future<Either<Failure, PlannedItem>> updatePlannedItem({
    required String id,
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  });

  Future<Either<Failure, void>> deletePlannedItem(String id);

  Future<Either<Failure, void>> completePlannedItem({
    required String id,
    required String paymentMethod,
    double? value,
  });
}
