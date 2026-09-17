import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';

class GetSavingsGoals implements UseCase<List<SavingsGoal>, NoParams> {
  final SavingsGoalRepository repository;

  GetSavingsGoals(this.repository);

  @override
  Future<Either<Failure, List<SavingsGoal>>> call(NoParams params) {
    return repository.getSavingsGoals();
  }
}
