import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/savings_goals/data/datasources/savings_goal_remote_data_source.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';

class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  final SavingsGoalRemoteDataSource remoteDataSource;

  SavingsGoalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals() {
    return _request(() => remoteDataSource.getSavingsGoals());
  }

  @override
  Future<Either<Failure, SavingsGoal>> addSavingsGoal({
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  }) {
    return _request(
      () => remoteDataSource.addSavingsGoal(
        name: name,
        amount: amount,
        period: period,
        plannedItemId: plannedItemId,
      ),
    );
  }

  @override
  Future<Either<Failure, SavingsGoal>> updateSavingsGoal({
    required String id,
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  }) {
    return _request(
      () => remoteDataSource.updateSavingsGoal(
        id: id,
        name: name,
        amount: amount,
        period: period,
        plannedItemId: plannedItemId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteSavingsGoal(String id) {
    return _request(() => remoteDataSource.deleteSavingsGoal(id));
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
