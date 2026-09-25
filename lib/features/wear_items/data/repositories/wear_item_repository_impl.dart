import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/wear_items/data/datasources/wear_item_remote_data_source.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';

class WearItemRepositoryImpl implements WearItemRepository {
  final WearItemRemoteDataSource remoteDataSource;

  WearItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WearItem>>> getWearItems({
    Set<WearStatus> statuses = const {},
  }) {
    return _request(() => remoteDataSource.getWearItems(statuses: statuses));
  }

  @override
  Future<Either<Failure, WearItemDetail>> getWearItemDetail(String id) {
    return _request(() => remoteDataSource.getWearItemDetail(id));
  }

  @override
  Future<Either<Failure, WearItem>> addWearItem({
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  }) {
    return _request(
      () => remoteDataSource.addWearItem(
        name: name,
        expectedLifespan: expectedLifespan,
        expectedLifespanUnit: expectedLifespanUnit,
        purchaseDate: purchaseDate,
        installationDate: installationDate,
        purchaseValue: purchaseValue,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<Either<Failure, WearItem>> updateWearItem({
    required String id,
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  }) {
    return _request(
      () => remoteDataSource.updateWearItem(
        id: id,
        name: name,
        expectedLifespan: expectedLifespan,
        expectedLifespanUnit: expectedLifespanUnit,
        purchaseDate: purchaseDate,
        installationDate: installationDate,
        purchaseValue: purchaseValue,
        categoryId: categoryId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteWearItem(String id) {
    return _request(() => remoteDataSource.deleteWearItem(id));
  }

  @override
  Future<Either<Failure, WearItem>> replaceWearItem({
    required String id,
    required DateTime purchaseDate,
    DateTime? installationDate,
    DateTime? removalDate,
    double? purchaseValue,
    String? paymentMethod,
  }) {
    return _request(
      () => remoteDataSource.replaceWearItem(
        id: id,
        purchaseDate: purchaseDate,
        installationDate: installationDate,
        removalDate: removalDate,
        purchaseValue: purchaseValue,
        paymentMethod: paymentMethod,
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
