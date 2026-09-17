import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';

class UpdateSavingsGoal
    implements UseCase<SavingsGoal, UpdateSavingsGoalParams> {
  final SavingsGoalRepository repository;

  UpdateSavingsGoal(this.repository);

  @override
  Future<Either<Failure, SavingsGoal>> call(UpdateSavingsGoalParams params) {
    return repository.updateSavingsGoal(
      id: params.id,
      name: params.name,
      amount: params.amount,
      period: params.period,
      plannedItemId: params.plannedItemId,
    );
  }
}

class UpdateSavingsGoalParams extends Equatable {
  final String id;
  final String name;
  final double amount;
  final SavingsGoalPeriod period;
  final String? plannedItemId;

  const UpdateSavingsGoalParams({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    this.plannedItemId,
  });

  @override
  List<Object?> get props => [id, name, amount, period, plannedItemId];
}
