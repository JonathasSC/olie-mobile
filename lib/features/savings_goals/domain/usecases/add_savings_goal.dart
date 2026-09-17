import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';

class AddSavingsGoal implements UseCase<SavingsGoal, AddSavingsGoalParams> {
  final SavingsGoalRepository repository;

  AddSavingsGoal(this.repository);

  @override
  Future<Either<Failure, SavingsGoal>> call(AddSavingsGoalParams params) {
    return repository.addSavingsGoal(
      name: params.name,
      amount: params.amount,
      period: params.period,
      plannedItemId: params.plannedItemId,
    );
  }
}

class AddSavingsGoalParams extends Equatable {
  final String name;
  final double amount;
  final SavingsGoalPeriod period;
  final String? plannedItemId;

  const AddSavingsGoalParams({
    required this.name,
    required this.amount,
    required this.period,
    this.plannedItemId,
  });

  @override
  List<Object?> get props => [name, amount, period, plannedItemId];
}
