import 'package:equatable/equatable.dart';

import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final double amount;
  final SavingsGoalPeriod period;
  final String? plannedItemId;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    this.plannedItemId,
  });

  @override
  List<Object?> get props => [id, name, amount, period, plannedItemId];
}
