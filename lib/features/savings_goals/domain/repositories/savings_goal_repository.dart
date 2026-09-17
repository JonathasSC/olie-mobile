import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

abstract class SavingsGoalRepository {
  Future<Either<Failure, List<SavingsGoal>>> getSavingsGoals();

  Future<Either<Failure, SavingsGoal>> addSavingsGoal({
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  });

  Future<Either<Failure, SavingsGoal>> updateSavingsGoal({
    required String id,
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  });

  Future<Either<Failure, void>> deleteSavingsGoal(String id);
}
