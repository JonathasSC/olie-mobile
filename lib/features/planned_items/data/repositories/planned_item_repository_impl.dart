import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/planned_items/data/datasources/planned_item_remote_data_source.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';

class PlannedItemRepositoryImpl implements PlannedItemRepository {
  final PlannedItemRemoteDataSource remoteDataSource;

  PlannedItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PlannedItem>>> getPlannedItems() {
    return _request(() => remoteDataSource.getPlannedItems());
  }

  @override
  Future<Either<Failure, PlannedItem>> addPlannedItem({
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  }) {
    return _request(
      () => remoteDataSource.addPlannedItem(
        name: name,
        priority: priority,
        estimatedValue: estimatedValue,
        estimatedDate: estimatedDate,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<Either<Failure, PlannedItem>> updatePlannedItem({
    required String id,
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  }) {
    return _request(
      () => remoteDataSource.updatePlannedItem(
        id: id,
        name: name,
        priority: priority,
        estimatedValue: estimatedValue,
        estimatedDate: estimatedDate,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deletePlannedItem(String id) {
    return _request(() => remoteDataSource.deletePlannedItem(id));
  }

  @override
  Future<Either<Failure, void>> completePlannedItem({
    required String id,
    required String paymentMethod,
    double? value,
  }) {
    return _request(
      () => remoteDataSource.completePlannedItem(
        id: id,
        paymentMethod: paymentMethod,
        value: value,
      ),
    );
  }

  Future<Either<Failure, T>> _request<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
