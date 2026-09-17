import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';

class DeleteSavingsGoal implements UseCase<void, DeleteSavingsGoalParams> {
  final SavingsGoalRepository repository;

  DeleteSavingsGoal(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSavingsGoalParams params) {
    return repository.deleteSavingsGoal(params.id);
  }
}

class DeleteSavingsGoalParams extends Equatable {
  final String id;

  const DeleteSavingsGoalParams(this.id);

  @override
  List<Object?> get props => [id];
}
