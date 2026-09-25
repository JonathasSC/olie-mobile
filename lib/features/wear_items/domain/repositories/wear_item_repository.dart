import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

abstract class WearItemRepository {
  Future<Either<Failure, List<WearItem>>> getWearItems({
    Set<WearStatus> statuses = const {},
  });

  Future<Either<Failure, WearItemDetail>> getWearItemDetail(String id);

  Future<Either<Failure, WearItem>> addWearItem({
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  });

  Future<Either<Failure, WearItem>> updateWearItem({
    required String id,
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  });

  Future<Either<Failure, void>> deleteWearItem(String id);

  Future<Either<Failure, WearItem>> replaceWearItem({
    required String id,
    required DateTime purchaseDate,
    DateTime? installationDate,
    DateTime? removalDate,
    double? purchaseValue,
    String? paymentMethod,
  });
}
